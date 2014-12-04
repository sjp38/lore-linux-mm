Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 61FB36B006C
	for <linux-mm@kvack.org>; Thu,  4 Dec 2014 02:51:51 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id et14so17569735pad.29
        for <linux-mm@kvack.org>; Wed, 03 Dec 2014 23:51:51 -0800 (PST)
Received: from ponies.io (ponies.io. [2600:3c01::f03c:91ff:fe6e:5e45])
        by mx.google.com with ESMTP id mt1si41779592pbb.128.2014.12.03.23.51.49
        for <linux-mm@kvack.org>;
        Wed, 03 Dec 2014 23:51:49 -0800 (PST)
Received: from cucumber.localdomain (58-6-54-190.dyn.iinet.net.au [58.6.54.190])
	by ponies.io (Postfix) with ESMTPSA id 0CE14A007
	for <linux-mm@kvack.org>; Thu,  4 Dec 2014 07:51:48 +0000 (UTC)
Date: Thu, 4 Dec 2014 18:51:46 +1100
From: Christian Marie <christian@ponies.io>
Subject: Re: isolate_freepages_block and excessive CPU usage by OSD process
Message-ID: <20141204075146.GA4961@cucumber.anchor.net.au>
References: <20141123093348.GA16954@cucumber.anchor.net.au>
 <CABYiri8LYukujETMCb4gHUQd=J-MQ8m=rGRiEkTD1B42Jh=Ksg@mail.gmail.com>
 <20141128080331.GD11802@js1304-P5Q-DELUXE>
 <54783FB7.4030502@suse.cz>
 <20141201083118.GB2499@js1304-P5Q-DELUXE>
 <20141202014724.GA22239@cucumber.bridge.anchor.net.au>
 <20141202045324.GC6268@js1304-P5Q-DELUXE>
 <20141202050608.GA11051@cucumber.bridge.anchor.net.au>
 <20141203075747.GB6276@js1304-P5Q-DELUXE>
 <20141204073045.GA2960@cucumber.anchor.net.au>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="PNTmBPCT7hxwcZjr"
Content-Disposition: inline
In-Reply-To: <20141204073045.GA2960@cucumber.anchor.net.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


--PNTmBPCT7hxwcZjr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

An extra note that may or may not be related, I just saw this whilst load
testing:

[177586.215195] swap_free: Unused swap offset entry 0000365b
[177586.215224] BUG: Bad page map in process ceph-osd  pte:006cb600
pmd:fea8a8067
[177586.215260] addr:00007f12dff8a000 vm_flags:00100077
anon_vma:ffff8807e6002000 mapping:          (null) index:7f12dff8a
[177586.215316] CPU: 22 PID: 48567 Comm: ceph-osd Tainted: GF   B
O--------------   3.10.0-123.9.3.anchor.x86_64 #1
[177586.215318] Hardware name: Dell Inc. PowerEdge R720xd/0X3D66, BIOS 2.2.2
01/16/2014
[177586.215319]  00007f12dff8a000 00000000cdae60bd ffff88062ff6bc70
ffffffff815e23bb
[177586.215324]  ffff88062ff6bcb8 ffffffff81167b48 00000000006cb600
00000007f12dff8a
[177586.215329]  ffff880fea8a8c50 00000000006cb600 00007f12dff8a000
00007f12dffde000
[177586.215333] Call Trace:
[177586.215337]  [<ffffffff815e23bb>] dump_stack+0x19/0x1b
[177586.215340]  [<ffffffff81167b48>] print_bad_pte+0x1a8/0x240
[177586.215343]  [<ffffffff811694b0>] unmap_page_range+0x5b0/0x860
[177586.215348]  [<ffffffff811697e1>] unmap_single_vma+0x81/0xf0
[177586.215353]  [<ffffffff8114fade>] ? lru_add_drain_cpu+0xce/0xe0
[177586.215358]  [<ffffffff8116a9f5>] zap_page_range+0x105/0x170
[177586.215361]  [<ffffffff81167354>] SyS_madvise+0x394/0x810
[177586.215366]  [<ffffffff810c30a0>] ? SyS_futex+0x80/0x180

This was on a 3.10 kernel with the two patches mentioned earlier in this
thread. I'm not suggesting it's related, just thought I'd note it as I've never
seen a bad page mapping before.

--PNTmBPCT7hxwcZjr
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUgBKQAAoJEMHZnoZn5OShCDwP/RKQlt+4eWx4/y6VD+4zLu1f
ja7syrWx+sz52ITGyWgI44MNPxyIipAP8CBDreR5+5lIeBTUBYfz/mMhfS7byFYd
DC/IneYsaV8QDdjgvOHgcfaJ+bEUWzcXhPZsdMq6uX94e1Rl1pPS9rEAIjvFv+5i
Ks4wjSanVRGSG5fm5yoTGphWvk9dC/rdKC1Zxi6DX4+68tq8CpKwspw0hGzD8rEg
FvT130rDhrOTm4SjmR2WPZVUuicxlylHWdnaznxvB7DAiZy9CEAoNayTfHy6WGW0
5HmdHcb9DAolXCxZ2uQgBatwQJWKri+9Be7XUw36SFo6+xfL+b8SjG2wybVEV0/m
DKp6R6w3gLMwSRbF9EZMG8d8/ttrdYkADLqGrAWNus11Cn/gnX/4cIgSY6fnV9lw
/chsc9og0OAlVNeLpeU3EAT6THzgqBKI9ZAU6FYn/a5l5mR/++iIGSjCf1joL8Re
eXQ9Fj9zigEKtFvIgUFhrUDNiwRUPn/After5rigdIdB6mBygOO+os50RHRbnU7J
hrPKMZ5y+0xKenoWuvb/rP1qDPG/okBqRD/aMvQHeGxyUt3ci2yH5pYzgL5Odl24
MNfem2Ez4FxVp68d4qjD5Q3i72C58eDRNAL6zFx/dS1aHSIHdjq7uVjwe/+0KUnS
+8yGVkB55s/fBJjjOPnL
=ppI1
-----END PGP SIGNATURE-----

--PNTmBPCT7hxwcZjr--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
