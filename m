Message-Id: <200202042227.g14MRFN12329@maile.telia.com>
Subject: New VM Testcase (2.4.18pre7 SWAPS) (2.4.17-rmap12b OK)
From: Roger Larsson <roger.larsson@norran.net> (by way of Roger Larsson
	<roger.larsson@norran.net>)
Date: Mon, 4 Feb 2002 23:24:11 +0100
MIME-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="------------Boundary-00=_BW41Q3VQ2036LQN91ETS"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: list linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--------------Boundary-00=_BW41Q3VQ2036LQN91ETS
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit

When examining Karlsbakk problem I got into one quite different myself.

I have a 256MB UP PII 933 MHz.
When running the included program with an option of 200
(serving 200 clients with streaming data a 10MB... on first run
it creates the data, from /dev/urandom - overkill from /dev/null is ok!)

ddteset.sh 200
[testcase initially written by Roy Sigurd Karlsbakk, he does not get
into this - but he has more RAM]

the 2.4.18pre7 goes into deep swap after awhile .
It is impossible to start a new login, et.c. finally
the dd processes begins to be OOM killed... not nice...

the 2.4.17-rmap12b handles this MUCH nicer!

/RogerL

--
Roger Larsson
Skelleftea
Sweden



--------------Boundary-00=_BW41Q3VQ2036LQN91ETS
Content-Type: application/x-shellscript;
  charset="iso-8859-1";
  name="ddtest.sh"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="ddtest.sh"

IyEvYmluL2Jhc2gKTUFYPTEwMApCUz0kKCgxMDI0ICogMjA0OCkpCkNPVU5UPTEwCkZQQVRIPS90
bXAKCmNhc2UgJCMgaW4KICAgICAgICAwKQogICAgICAgICAgICAgICAgaT0kQ09VTlQKICAgICAg
ICAgICAgICAgIDs7CgogICAgICAgIDEpCiAgICAgICAgICAgICAgICBpPSQxCiAgICAgICAgICAg
ICAgICA7OwogICAgICAgICopCiAgICAgICAgICAgICAgICBwcmludGYgIkVycm9yOlxuU3ludGF4
OiAkMCBbIG51bWZpbGVzIF1cbiIKICAgICAgICAgICAgICAgIGV4aXQKICAgICAgICAgICAgICAg
IDs7CmVzYWMKCmlmIFtbICRpIC1sdCAxIF1dOyB0aGVuCiAgICAgICAgcHJpbnRmICJDYW4ndCBy
ZWFkICRpIGZpbGVzXG4iCiAgICAgICAgZXhpdApmaQoKaWYgdGVzdCBcISAtZiBgcHJpbnRmICIl
cy9maWxlJTA0ZC5tcDAiICRGUEFUSCAkaWA7IHRoZW4KICAgICAgICBjPSRpCiAgICAgICAgZWNo
byAiV3JpdGluZyAkYyBmaWxlcy4uLiIKCiAgICAgICAgd2hpbGUgW1sgJGMgLWd0IDAgXV07IGRv
CiAgICAgICAgICAgICAgICBmaWxlPWBwcmludGYgIiVzL2ZpbGUlMDRkLm1wMCIgJEZQQVRIICRj
YAogICAgICAgICAgICAgICAgdG91Y2ggJGZpbGUKICAgICAgICAgICAgICAgIGRkIGlmPS9kZXYv
dXJhbmRvbSBvZj0kZmlsZSBicz0kQlMgY291bnQ9JENPVU5UCiAgICAgICAgICAgICAgICBjPSQo
KCAkYyAtIDEgKSkKICAgICAgICBkb25lCmZpCgpwcmludGYgIlJlYWRpbmcgJGkgZmlsZXMuLlxu
IgoKd2hpbGUgW1sgJGkgLWd0IDAgXV07IGRvCiAgICAgICAgZmlsZT1gcHJpbnRmICIlcy9maWxl
JTA0ZC5tcDAiICRGUEFUSCAkaWAKICAgICAgICBkZCBpZj0kZmlsZSBvZj0vZGV2L251bGwgYnM9
JEJTICYKICAgICAgICBpPSQoKCAkaSAtIDEgKSkKZG9uZQo=

--------------Boundary-00=_BW41Q3VQ2036LQN91ETS--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
