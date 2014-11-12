Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id DF3306B00DF
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 03:14:14 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id g10so11694011pdj.24
        for <linux-mm@kvack.org>; Wed, 12 Nov 2014 00:14:14 -0800 (PST)
Received: from m15-38.126.com (m15-38.126.com. [220.181.15.38])
        by mx.google.com with ESMTP id ml1si5525529pdb.20.2014.11.12.00.14.11
        for <linux-mm@kvack.org>;
        Wed, 12 Nov 2014 00:14:13 -0800 (PST)
Date: Wed, 12 Nov 2014 16:13:30 +0800 (CST)
From: =?GBK?B?x9jfrrjq?= <michaelbest002@126.com>
Subject: How to disable fault-around by debugfs?
Content-Type: multipart/alternative;
	boundary="----=_Part_505743_1587407499.1415780010566"
MIME-Version: 1.0
Message-ID: <267163c2.1f570.149a3108a46.Coremail.michaelbest002@126.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kirill@shutemov.name
Cc: kernelnewbies <kernelnewbies@kernelnewbies.org>, linux-mm <linux-mm@kvack.org>

------=_Part_505743_1587407499.1415780010566
Content-Type: text/plain; charset=GBK
Content-Transfer-Encoding: base64

SGksCgoKSSdtIGp1c3QgdGhlIGd1eSB3aG8gYXNrZWQgYSBxdWVzdGlvbiBhYm91dCB0aGUgcGFn
ZSBmYXVsdCBoYW5kbGVyIGRheXMgYWdvLiBUaGFua3MgZm9yIHRlbGxpbmcgbWUgYWJvdXQgdGhl
IGZhdWx0LWFyb3VuZCBmZWF0dXJlLiAKCgpZb3UgYWxzbyB0b2xkIG1lIHRoYXQgdGhpcyBmZWF0
dXJlIGNvdWxkIGJlIGRpc2FibGVkIGluIGRlYnVnZnMsIGJ1dCBJIHN0aWxsIGRvbid0IGtub3cg
aG93IHRvIGFjaGlldmUgaXQgYnkgZGVidWdmcy4gSSBvbmx5IGtub3cgdGhhdCBkZWJ1Z2ZzIGlz
IHNvbWV0aGluZyB0aGF0IGRldmVsb3BlcnMgY291bGQgcHV0IGluZm9ybWF0aW9uIGFib3V0IGtl
cm5lbCB0aGVyZS4gU28gY291bGQgeW91IHRlbGwgbWUgaG93IHRvIGRpc2FibGUgZmF1bHQtYXJv
dW5kIGZlYXR1cmUgYnkgZGVidWdmcz8gT3IgaXMgaXQgT0sgdG8gZGlyZWN0bHkgbW9kaWZ5IGtl
cm5lbD8gSSBmaW5kIHdoZXJlIGl0IGlzIGxvY2F0ZWQgaW4gc291cmNlOgoKCjM1MTggICAgIGlm
ICh2bWEtPnZtX29wcy0+bWFwX3BhZ2VzKSB7CjM1MTkgICAgICAgICBwdGUgPSBwdGVfb2Zmc2V0
X21hcF9sb2NrKG1tLCBwbWQsIGFkZHJlc3MsICZwdGwpOwozNTIwICAgICAgICAgZG9fZmF1bHRf
YXJvdW5kKHZtYSwgYWRkcmVzcywgcHRlLCBwZ29mZiwgZmxhZ3MpOwozNTIxICAgICAgICAgaWYg
KCFwdGVfc2FtZSgqcHRlLCBvcmlnX3B0ZSkpCjM1MjIgICAgICAgICAgICAgZ290byB1bmxvY2tf
b3V0OwozNTIzICAgICAgICAgcHRlX3VubWFwX3VubG9jayhwdGUsIHB0bCk7CjM1MjQgICAgIH0K
CgpUaGFuayB5b3UgdmVyeSBtdWNoIQpCZXN0IHJlZ2FyZHM=
------=_Part_505743_1587407499.1415780010566
Content-Type: text/html; charset=GBK
Content-Transfer-Encoding: base64

PGRpdiBzdHlsZT0ibGluZS1oZWlnaHQ6MS43O2NvbG9yOiMwMDAwMDA7Zm9udC1zaXplOjE0cHg7
Zm9udC1mYW1pbHk6QXJpYWwiPjxkaXY+SGksPC9kaXY+PGRpdj48YnI+PC9kaXY+PGRpdj5JJ20g
anVzdCB0aGUgZ3V5IHdobyBhc2tlZCBhIHF1ZXN0aW9uIGFib3V0IHRoZSBwYWdlIGZhdWx0IGhh
bmRsZXIgZGF5cyBhZ28uIFRoYW5rcyBmb3IgdGVsbGluZyBtZSBhYm91dCB0aGUgZmF1bHQtYXJv
dW5kIGZlYXR1cmUuJm5ic3A7PC9kaXY+PGRpdj48YnI+PC9kaXY+PGRpdj5Zb3UgYWxzbyB0b2xk
IG1lIHRoYXQgdGhpcyBmZWF0dXJlIGNvdWxkIGJlIGRpc2FibGVkIGluIGRlYnVnZnMsIGJ1dCBJ
IHN0aWxsIGRvbid0IGtub3cgaG93IHRvIGFjaGlldmUgaXQgYnkgZGVidWdmcy4gSSBvbmx5IGtu
b3cgdGhhdCBkZWJ1Z2ZzIGlzIHNvbWV0aGluZyB0aGF0IGRldmVsb3BlcnMgY291bGQgcHV0IGlu
Zm9ybWF0aW9uIGFib3V0IGtlcm5lbCB0aGVyZS4gU28gY291bGQgeW91IHRlbGwgbWUgaG93IHRv
IGRpc2FibGUgZmF1bHQtYXJvdW5kIGZlYXR1cmUgYnkgZGVidWdmcz8gT3IgaXMgaXQgT0sgdG8g
ZGlyZWN0bHkgbW9kaWZ5IGtlcm5lbD8gSSBmaW5kIHdoZXJlIGl0IGlzIGxvY2F0ZWQgaW4gc291
cmNlOjwvZGl2PjxkaXY+PGJyPjwvZGl2PjxkaXY+PGRpdj4zNTE4ICZuYnNwOyAmbmJzcDsgaWYg
KHZtYS0mZ3Q7dm1fb3BzLSZndDttYXBfcGFnZXMpIHs8L2Rpdj48ZGl2PjM1MTkgJm5ic3A7ICZu
YnNwOyAmbmJzcDsgJm5ic3A7IHB0ZSA9IHB0ZV9vZmZzZXRfbWFwX2xvY2sobW0sIHBtZCwgYWRk
cmVzcywgJmFtcDtwdGwpOzwvZGl2PjxkaXY+MzUyMCAmbmJzcDsgJm5ic3A7ICZuYnNwOyAmbmJz
cDsgZG9fZmF1bHRfYXJvdW5kKHZtYSwgYWRkcmVzcywgcHRlLCBwZ29mZiwgZmxhZ3MpOzwvZGl2
PjxkaXY+MzUyMSAmbmJzcDsgJm5ic3A7ICZuYnNwOyAmbmJzcDsgaWYgKCFwdGVfc2FtZSgqcHRl
LCBvcmlnX3B0ZSkpPC9kaXY+PGRpdj4zNTIyICZuYnNwOyAmbmJzcDsgJm5ic3A7ICZuYnNwOyAm
bmJzcDsgJm5ic3A7IGdvdG8gdW5sb2NrX291dDs8L2Rpdj48ZGl2PjM1MjMgJm5ic3A7ICZuYnNw
OyAmbmJzcDsgJm5ic3A7IHB0ZV91bm1hcF91bmxvY2socHRlLCBwdGwpOzwvZGl2PjxkaXY+MzUy
NCAmbmJzcDsgJm5ic3A7IH08L2Rpdj48L2Rpdj48ZGl2Pjxicj48L2Rpdj48ZGl2PlRoYW5rIHlv
dSB2ZXJ5IG11Y2ghPC9kaXY+PGRpdj5CZXN0IHJlZ2FyZHM8L2Rpdj48L2Rpdj48YnI+PGJyPjxz
cGFuIHRpdGxlPSJuZXRlYXNlZm9vdGVyIj48c3BhbiBpZD0ibmV0ZWFzZV9tYWlsX2Zvb3RlciI+
PC9zcGFuPjwvc3Bhbj4=
------=_Part_505743_1587407499.1415780010566--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
