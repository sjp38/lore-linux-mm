Date: Thu, 5 Apr 2001 13:08:25 -0400 (EDT)
From: <majer@endeca.com>
Subject: memory allocation problems
Message-ID: <Pine.LNX.4.21.0104051257570.6783-300000@caffeine.ops.endeca.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="717328-2118941976-986490505=:6783"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: loki@endeca.com
List-ID: <linux-mm.kvack.org>

--717328-2118941976-986490505=:6783
Content-Type: TEXT/PLAIN; charset=US-ASCII


  Hi. Im hoping someone on here can help me out. I posted something
  similar to this back in June 2000 and was hoping the 2.4 kernel
  would provide a fix.

  Essentially, the problem can be summarized to be that on a machine
  with ample ram (2G, 4G, etc), I am unable to malloc a gig if I ask 
  for the memory in small ( <= 128k) chunks. I've enclosed some results 
  and a little program which was put together to demonstrate the problems
  we're having.  All of the failures seem to occur around 930MB.

  I'm more than happy to try any tunings, patches, etc and my 
  time is at your disposal.

  Thanks,

  Karl

----
        Karl Majer                          majerNO@SPAMendeca.com              
        Sr Systems Architect                617 577 7999 xt 251                

 "Think for yourselves and let others enjoy the privilege to do so, too."
						     --Voltaire

--717328-2118941976-986490505=:6783
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="memgrab.c"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.21.0104051308250.6783@caffeine.ops.endeca.com>
Content-Description: 
Content-Disposition: attachment; filename="memgrab.c"

I2luY2x1ZGU8c3RkaW8uaD4NCiNpbmNsdWRlPHVuaXN0ZC5oPg0KI2luY2x1
ZGU8c3RkbGliLmg+DQojaW5jbHVkZTxlcnJuby5oPg0KDQp1bnNpZ25lZCBp
bnQgaSxudW0sYml0ZXMsdG90YWwsZGVsYXk9MDsNCmNoYXIgKiptZW1ob2c7
DQoNCmludCBtYWluKGludCBhcmdjLGNoYXIgKmFyZ3ZbXSl7DQoNCiAgaWYo
YXJnYyE9NCl7DQogICAgZnByaW50ZihzdGRlcnIsInVzYWdlOiAlcyBbIyBv
ZiBjaHVua3NdIFtieXRlcyBwZXIgY2h1bmtdIFtkZWxheSBpbiBzZWNdXG4i
LGFyZ3ZbMF0pOw0KICAgIHJldHVybigxKTsNCiAgfSANCg0KICBudW09YXRv
aShhcmd2WzFdKTsNCiAgYml0ZXM9YXRvaShhcmd2WzJdKTsNCiAgZGVsYXk9
YXRvaShhcmd2WzNdKTsNCg0KICBtZW1ob2c9bWFsbG9jKHNpemVvZihjaGFy
KikgKiBudW0pOyANCiAgaWYoIW1lbWhvZyl7DQogICAgZnByaW50ZihzdGRl
cnIsIm1hbGxvYyBlcnJvciAlc1xuIixzdHJlcnJvcihlcnJubykpOyAgDQog
ICAgZXhpdCgxKTsNCiAgfQ0KDQogIGZvcihpPTA7aTxudW07aSsrKXsNCiAg
ICAqbWVtaG9nPW1hbGxvYyhiaXRlcyk7DQogICAgaWYoISptZW1ob2cpew0K
ICAgICAgZnByaW50ZihzdGRlcnIsIm1hbGxvYyBlcnJvciAlc1xuIixzdHJl
cnJvcihlcnJubykpOyAgDQogICAgICBleGl0KDEpOw0KICAgIH0NCiAgICB0
b3RhbCs9Yml0ZXM7DQogICAgcHJpbnRmKCIjJXUgKCVYKSAoJVgpIGFsbG9j
YXRlZCAldSBieXRlcyB0b3RhbC5cbiIsaSxtZW1ob2csKm1lbWhvZyx0b3Rh
bCk7DQogICAgbWVtaG9nKys7DQogICAgc2xlZXAoZGVsYXkpOw0KICB9ICAN
Cg0KIHJldHVybigwKTsNCn0gDQogIA0KDQo=
--717328-2118941976-986490505=:6783
Content-Type: TEXT/PLAIN; charset=US-ASCII; name=results
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.21.0104051308251.6783@caffeine.ops.endeca.com>
Content-Description: 
Content-Disposition: attachment; filename=results

ICBUaGUgZmllbGRzIGFyZTogDQogIEl0ZXJhdGlvbiwgQWRkciBvZiBwdHIs
IEFkZHIgc3RvcmVkIGJ5IHB0ciwgYWxsb2MnZCBtZW0NCg0KICBzaXplOiA0
MDk2DQogICMyMjg4NTIgKDQwMUYwN0Q4KSAoM0ZGRkM5NDgpIGFsbG9jYXRl
ZCA5MzczODE4ODggYnl0ZXMgdG90YWwuDQogICMyMjg4NTMgKDQwMUYwN0RD
KSAoM0ZGRkQ5NTApIGFsbG9jYXRlZCA5MzczODU5ODQgYnl0ZXMgdG90YWwu
DQogIG1hbGxvYyBlcnJvciBDYW5ub3QgYWxsb2NhdGUgbWVtb3J5DQogIA0K
ICBzaXplOiA4MTkyDQogICMxMTQ1MzYgKDQwMTgwREE4KSAoM0ZGRjk0RTgp
IGFsbG9jYXRlZCA5MzgyODcxMDQgYnl0ZXMgdG90YWwuDQogICMxMTQ1Mzcg
KDQwMTgwREFDKSAoM0ZGRkI0RjApIGFsbG9jYXRlZCA5MzgyOTUyOTYgYnl0
ZXMgdG90YWwuDQogIG1hbGxvYyBlcnJvciBDYW5ub3QgYWxsb2NhdGUgbWVt
b3J5DQogICANCiAgc2l6ZTogMTYzODQNCiAgIzU3Mjk0ICg0MDE0OEY0MCkg
KDNGRkYxODE4KSBhbGxvY2F0ZWQgOTM4NzIxMjgwIGJ5dGVzIHRvdGFsLg0K
ICAjNTcyOTUgKDQwMTQ4RjQ0KSAoM0ZGRjU4MjApIGFsbG9jYXRlZCA5Mzg3
Mzc2NjQgYnl0ZXMgdG90YWwuDQogIG1hbGxvYyBlcnJvciBDYW5ub3QgYWxs
b2NhdGUgbWVtb3J5DQogIA0KICBzaXplOiAzMjc2OA0KICAjMjg2NTMgKDQw
MTJDRkJDKSAoM0ZGRTk5MTApIGFsbG9jYXRlZCA5Mzg5MzQyNzIgYnl0ZXMg
dG90YWwuDQogICMyODY1NCAoNDAxMkNGQzApICgzRkZGMTkxOCkgYWxsb2Nh
dGVkIDkzODk2NzA0MCBieXRlcyB0b3RhbC4NCiAgbWFsbG9jIGVycm9yIENh
bm5vdCBhbGxvY2F0ZSBtZW1vcnkNCiAgDQogIHNpemU6IDY1NTM2DQogICMx
NDMyNSAoODA1Nzk3QykgKDNGRkM1OTU4KSBhbGxvY2F0ZWQgOTM4ODY4NzM2
IGJ5dGVzIHRvdGFsLg0KICAjMTQzMjYgKDgwNTc5ODApICgzRkZENTk2MCkg
YWxsb2NhdGVkIDkzODkzNDI3MiBieXRlcyB0b3RhbC4NCiAgIzE0MzI3ICg4
MDU3OTg0KSAoM0ZGRTU5NjgpIGFsbG9jYXRlZCA5Mzg5OTk4MDggYnl0ZXMg
dG90YWwuDQogIG1hbGxvYyBlcnJvciBDYW5ub3QgYWxsb2NhdGUgbWVtb3J5
DQogIA0KICBzaXplOiAxMzEwNzINCiAgIzgxODYgKDgwNTE5OTApICgzRkY5
Rjk4MCkgYWxsb2NhdGVkIDEwNzMwODY0NjQgYnl0ZXMgdG90YWwuDQogICM4
MTg3ICg4MDUxOTk0KSAoM0ZGQkY5ODgpIGFsbG9jYXRlZCAxMDczMjE3NTM2
IGJ5dGVzIHRvdGFsLg0KICBtYWxsb2MgZXJyb3IgQ2Fubm90IGFsbG9jYXRl
IG1lbW9yeQ0KICANCiAgc2l6ZTogMjYyMTQ0DQogICM0MDk0ICg4MDREOUEw
KSAoMzdGRDM5QTApIGFsbG9jYXRlZCAxMDczNDc5NjgwIGJ5dGVzIHRvdGFs
Lg0KICAjNDA5NSAoODA0RDlBNCkgKDM4MDEzOUE4KSBhbGxvY2F0ZWQgMTA3
Mzc0MTgyNCBieXRlcyB0b3RhbC4NCiAgc3VjY2Vzcw0KICAgDQo=
--717328-2118941976-986490505=:6783--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
