Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA13599
	for <linux-mm@kvack.org>; Tue, 5 Jan 1999 08:26:21 -0500
Subject: Re: [patch] arca-vm-6, killed kswapd [Re: [patch] new-vm improvement , [Re: 2.2.0 Bug summary]]
References: <Pine.LNX.3.96.990105124806.494E-100000@laser.bogus>
Reply-To: Zlatko.Calusic@CARNet.hr
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 05 Jan 1999 14:23:23 +0100
In-Reply-To: Andrea Arcangeli's message of "Tue, 5 Jan 1999 12:49:58 +0100 (CET)"
Message-ID: <8767alua44.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a MIME multipart message.  If you are reading
this, you shouldn't.

--=-=-=

Andrea Arcangeli <andrea@e-mind.com> writes:

> On 5 Jan 1999, Zlatko Calusic wrote:
> 
> > At this point (output of Alt-SysRq-M), machine locked:
> 
> Are you been able to continue using SysRq-K?

Erm... I continued with *&#&%$ Alt-SysRq-{S,U,B}.
That worked for me. :)

> 
> Could you reproduce and press ALT-right+Scroll-Lock and tell me what the
> kernel was executing at that time...
>

I tried few times, but to no avail. Looks like subtle race, bad news
for you, unfortunately.

*BUT*, after I pressed ctrl-c against mmap-sync in one of the torture
tests, the program stuck in down_failed (loadav += 2). Few minutes
later machine got very unstable and I decided to reboot it. Go figure.

> Could you send me also the proggy for the shared-mmaps to allow me to
> reproduce?
> 

Sure, just be careful. :)


--=-=-=
Content-Type: application/octet-stream
Content-Disposition: attachment
Content-Description: Exercise shared mappings
Content-Transfer-Encoding: base64

I2luY2x1ZGUgPHVuaXN0ZC5oPgojaW5jbHVkZSA8ZmNudGwuaD4KI2luY2x1ZGUgPHN5cy9t
bWFuLmg+CiNpbmNsdWRlIDxzeXMvdHlwZXMuaD4KI2luY2x1ZGUgPHN5cy9zdGF0Lmg+Cgov
KiAKICogZmlsZSBzaXplLCBzaG91bGQgYmUgaGFsZiBvZiB0aGUgc2l6ZSBvZiB0aGUgcGh5
c2ljYWwgbWVtb3J5CiAqLwojZGVmaW5lIEZJTEVTSVpFICgzMiAqIDEwMjQgKiAxMDI0KQoK
aW50IG1haW4odm9pZCkKewogIGNoYXIgKnB0cjsKICBpbnQgZmQsIGk7CiAgY2hhciBjID0g
J0EnOwogIHBpZF90IHBpZDsKCiAgaWYgKChmZCA9IG9wZW4oImZvbyIsIE9fUkRXUiB8IE9f
Q1JFQVQgfCBPX1RSVU5DKSkgPT0gLTEpIHsKICAgIHBlcnJvcigib3BlbiIpOwogICAgZXhp
dCgxKTsKICB9CiAgbHNlZWsoZmQsIEZJTEVTSVpFIC0gMSwgU0VFS19TRVQpOwogIC8qIHdy
aXRlIG9uZSBieXRlIHRvIGV4dGVuZCB0aGUgZmlsZSAqLwogIHdyaXRlKGZkLCAmZmQsIDEp
OwoKICAvKiBnZXQgYSBzaGFyZWQgbWFwcGluZyAqLwogIHB0ciA9IG1tYXAoMCwgRklMRVNJ
WkUsIFBST1RfUkVBRCB8IFBST1RfV1JJVEUsIE1BUF9TSEFSRUQsIGZkLCAwKTsKICBpZiAo
cHRyID09IE5VTEwpIHsKICAgIHBlcnJvcigibW1hcCIpOwogICAgZXhpdCgxKTsKICB9Cgog
IC8qIHRvdWNoIGFsbCBwYWdlcyBpbiB0aGUgbWFwcGluZyAqLwogIGZvciAoaSA9IDA7IGkg
PCBGSUxFU0laRTsgaSArPSA0MDk2KQogICAgcHRyW2ldID0gYzsKCiAgd2hpbGUgKDEpIHsK
ICAgIGlmICgocGlkID0gZm9yaygpKSkgeyAvKiBwYXJlbnQsIHdhaXQgKi8KICAgICAgd2Fp
dHBpZChwaWQsIE5VTEwsIDApOwogICAgfSBlbHNlIHsgLyogY2hpbGQsIGV4ZWMgYXdheSAq
LwojaWYgMAogICAgICBleGVjbCgiL2Jpbi9lY2hvIiwgImVjaG8iLCAiYmxhaCIpOwojZWxz
ZQogICAgICBmc3luYyhmZCk7CiAgICAgIHByaW50ZigiYmxhaFxuIik7CiAgICAgIGV4aXQo
MCk7CiNlbmRpZgogICAgfQogICAgc2xlZXAoNSk7CiAgfQp9Cg==

--=-=-=


P.S. Apologies for too many jokes, I didn't sleep at all last night. ;)
-- 
Zlatko

--=-=-=--
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
