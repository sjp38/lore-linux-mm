Date: Mon, 6 Dec 1999 07:45:56 -0800
Message-Id: <199912061545.HAA27422@ns1.filetron.com>
Mime-Version: 1.0
From: AndreaE <AndreaE@linuxstart.com>
Subject: Linux Without MMU
Content-Type: multipart/mixed; boundary="----------=_944495155-27420-0"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Linux MM List - ( SL )" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format...

------------=_944495155-27420-0
Content-Type: text/plain
Content-Disposition: inline

AndreaE <AndreaE@linuxstart.com> wrote:
Hi , 
..i'm working on Linux Kernel porting on HardWare Without MMU. This is not impossible ( uCLinux Es. ), but i'm bored to read thousend &
thousend of code without a Guide Line. My target is port a full playable linux apps on ARM7TDMI ( very low cost & hi performance CPU but without mmu ). I'm using a uCSimm like example. I've difficulties to understand the new gadget from kernel 2.0.38 (uses by uCSim &  Co. ) and kernel 2.2.12 with ARM support.

Is There anyone that have some experience with this problem or have some tips to tell me ???

Is There anyone interesting to help me to do it ??

I Hope that it's not off topics !!!

Thx4All.
Hi By Andrea.



------
Do you do Linux? :)
Get your FREE @linuxstart.com email address at: http://www.linuxstart.com

------------=_944495155-27420-0
Content-Type: text/html ; name="son1.html"
Content-Disposition: inline; filename="son1.html"
Content-Transfer-Encoding: base64

PEhUTUw+DQo8SEVBRD4NCg0KPFNDUklQVCBMQU5HVUFHRT0iSmF2YVNjcmlw
dCI+DQo8IS0tIE9yaWdpbmFsOiAgaHR0cDovL3d3dy5pcnQub3JnIC0tPg0K
DQo8IS0tIFRoaXMgc2NyaXB0IGFuZCBtYW55IG1vcmUgYXJlIGF2YWlsYWJs
ZSBmcmVlIG9ubGluZSBhdCAtLT4NCjwhLS0gVGhlIEphdmFTY3JpcHQgU291
cmNlISEgaHR0cDovL2phdmFzY3JpcHQuaW50ZXJuZXQuY29tIC0tPg0KDQo8
IS0tIEJlZ2luDQp2YXIgbWltZXR5cGUgPSAnYXVkaW8vbWlkJzsNCnZhciBz
b3VuZGZpbGUgPSAnY2FueW9uLm1pZCc7DQoNCnZhciBjYW5fcGxheSA9IGZh
bHNlOw0KaWYgKG5hdmlnYXRvci5taW1lVHlwZXMpDQp7DQogIGlmIChuYXZp
Z2F0b3IubWltZVR5cGVzW21pbWV0eXBlXSAhPSBudWxsKQ0KICB7DQogICAg
aWYgKG5hdmlnYXRvci5taW1lVHlwZXNbbWltZXR5cGVdLmVuYWJsZWRQbHVn
aW4gIT0gbnVsbCkNCiAgICB7DQogICAgICAgIGNhbl9wbGF5ID0gdHJ1ZTsN
CiAgICAgICAgZG9jdW1lbnQud3JpdGUoJzxFTUJFRCBTUkM9JyArIHNvdW5k
ZmlsZSArICcgSElEREVOPVRSVUUgTE9PUD1GQUxTRSBBVVRPU1RBUlQ9RkFM
U0U+Jyk7DQogICAgfQ0KICB9DQp9DQpmdW5jdGlvbiBwbGF5U291bmQoKSB7
DQppZiAoZG9jdW1lbnQuZW1iZWRzICYmIGNhbl9wbGF5KSB7DQppZiAobmF2
aWdhdG9yLmFwcE5hbWUgPT0gJ05ldHNjYXBlJykNCmRvY3VtZW50LmVtYmVk
c1swXS5wbGF5KCk7DQplbHNlDQpkb2N1bWVudC5lbWJlZHNbMF0ucnVuKCk7
DQogICB9DQp9DQovLyAgRW5kIC0tPg0KPC9zY3JpcHQ+DQo8L0hFQUQ+DQoN
CjxCT0RZPg0KDQo8YSBocmVmPSIjIiBvbkNsaWNrPSJwbGF5U291bmQoKSI+
PGltZyBzcmM9InRqc2J1dHRvbi5naWYiIHdpZHRoPSI4MSIgaGVpZ2h0PSIz
MSIgYm9yZGVyPSIwIj48L2E+DQoNCjxwPjxjZW50ZXI+DQo8Zm9udCBmYWNl
PSJhcmlhbCwgaGVsdmV0aWNhIiBTSVpFPSItMiI+RnJlZSBKYXZhU2NyaXB0
cyBwcm92aWRlZDxicj4NCmJ5IDxhIGhyZWY9Imh0dHA6Ly9qYXZhc2NyaXB0
c291cmNlLmNvbSI+VGhlIEphdmFTY3JpcHQgU291cmNlPC9hPjwvZm9udD4N
CjwvY2VudGVyPjxwPg0KDQo8L0JPRFk+DQo8L0hUTUw+

------------=_944495155-27420-0--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
