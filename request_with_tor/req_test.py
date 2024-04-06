# start "sudo tor" with adequate torrc; https://github.com/deedy5/requests_tor?tab=readme-ov-file
# FIX: mit control port passwort!!

from requests_tor import RequestsTor

rt = RequestsTor(tor_ports=(9050,), tor_cport=9051, autochange_id=1)

urls = [f'https://api.ipify.org?format=json' for _ in range(10)]
results = rt.get_urls(urls)
for r in results:
    print(r.text)