Return-Path: <SRS0=ZelW=WN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91D70C3A59E
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 08:09:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 52C2E2077C
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 08:09:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="PFmZ3tEw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 52C2E2077C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DD2C76B000C; Sat, 17 Aug 2019 04:09:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D834B6B000D; Sat, 17 Aug 2019 04:09:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C99FF6B000E; Sat, 17 Aug 2019 04:09:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0088.hostedemail.com [216.40.44.88])
	by kanga.kvack.org (Postfix) with ESMTP id A8EB36B000C
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 04:09:50 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 4D40C181AC9C9
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 08:09:50 +0000 (UTC)
X-FDA: 75831196140.28.songs74_38b4b3176575e
X-HE-Tag: songs74_38b4b3176575e
X-Filterd-Recvd-Size: 5023
Received: from pegase1.c-s.fr (pegase1.c-s.fr [93.17.236.30])
	by imf16.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 08:09:49 +0000 (UTC)
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 469Xsk4XFmz9typx;
	Sat, 17 Aug 2019 10:09:46 +0200 (CEST)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=PFmZ3tEw; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id sNvX-0_3f_4K; Sat, 17 Aug 2019 10:09:46 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 469Xsk3PNRz9typs;
	Sat, 17 Aug 2019 10:09:46 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1566029386; bh=pVI9gY6iiTOKFqgekWFv504Tf/QYksOUjRjQFOu2kD0=;
	h=Subject:To:References:From:Date:In-Reply-To:From;
	b=PFmZ3tEwbCcnorGnd5QrmBxwxFFSuDEhTO5ZjS4uBLNisb+UKUNsl94HoIWJQIWXF
	 bOBEfuKIST6lerMbAPKSPdZzybS4qFVQ/HaIuSoZO3dGUCBsiLoMn8RJkAXWz528uW
	 yVq0TMp+3G9mqWqk98b8zsX+IrJ6HBJWVGviJp44=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 9214B8B793;
	Sat, 17 Aug 2019 10:09:47 +0200 (CEST)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id Lp6brMJxdad5; Sat, 17 Aug 2019 10:09:47 +0200 (CEST)
Received: from [192.168.232.53] (unknown [192.168.232.53])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id EAA278B790;
	Sat, 17 Aug 2019 10:09:46 +0200 (CEST)
Subject: Re: [Bug 204371] BUG kmalloc-4k (Tainted: G W ): Object padding
 overwritten
To: bugzilla-daemon@bugzilla.kernel.org, linuxppc-dev@lists.ozlabs.org,
 Andrew Morton <akpm@linux-foundation.org>,
 Linux Memory Management List <linux-mm@kvack.org>,
 linux-btrfs@vger.kernel.org, erhard_f@mailbox.org, Chris Mason <clm@fb.com>,
 Josef Bacik <josef@toxicpanda.com>, David Sterba <dsterba@suse.com>,
 Michael Ellerman <mpe@ellerman.id.au>
References: <bug-204371-206035@https.bugzilla.kernel.org/>
 <bug-204371-206035-O9m4mwJN9f@https.bugzilla.kernel.org/>
From: christophe leroy <christophe.leroy@c-s.fr>
Message-ID: <e8b5b450-bdb2-6be8-8b14-bd76b81de9a0@c-s.fr>
Date: Sat, 17 Aug 2019 10:09:46 +0200
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <bug-204371-206035-O9m4mwJN9f@https.bugzilla.kernel.org/>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
X-Antivirus: Avast (VPS 190816-4, 16/08/2019), Outbound message
X-Antivirus-Status: Clean
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



Le 30/07/2019 =C3=A0 20:52, bugzilla-daemon@bugzilla.kernel.org a =C3=A9c=
rit=C2=A0:
> https://bugzilla.kernel.org/show_bug.cgi?id=3D204371
>=20
> --- Comment #2 from Andrew Morton (akpm@linux-foundation.org) ---
> (switched to email.  Please respond via emailed reply-to-all, not via t=
he
> bugzilla web interface).

Reply all replies to bugzilla-daemon@bugzilla.kernel.org only.


[...]


>=20
> cc'ing various people here.

Hum ... only got that email through the bugzilla interface, and CC'ed=20
people don't show up.


>=20
> I suspect proc_cgroup_show() is innocent and that perhaps
> bpf_prepare_filter() had a memory scribble.  iirc there has been at
> least one recent pretty serious bpf fix applied recently.  Can others
> please take a look?
>=20
> (Seriously - please don't modify this report via the bugzilla web inter=
face!)
>=20

Haven't got the original CC'ed list, so please reply with missing Cc's=20
if any.

We have well progressed on this case.

Erhard made a relation being this "Object padding overwritten" issue=20
arising on any driver, and the presence of the BTRFS driver.

Then he was able to bisect the issue to:

commit 69d2480456d1baf027a86e530989d7bedd698d5f
Author: David Sterba <dsterba@suse.com>
Date:   Fri Jun 29 10:56:44 2018 +0200

     btrfs: use copy_page for copying pages instead of memcpy

     Use the helper that's possibly optimized for full page copies.

     Signed-off-by: David Sterba <dsterba@suse.com>



After looking in the code, it has appeared that some of the said "pages"=20
were allocated with "kzalloc()".

Using the patch https://patchwork.ozlabs.org/patch/1148033/ Erhard=20
confirmed that some btrfs functions were calling copy_page() with=20
misaligned destinations.

copy_page(), at least on powerpc, expects cache aligned destination.

The patch https://patchwork.ozlabs.org/patch/1148606/ fixes the issue.

Christophe

---
L'absence de virus dans ce courrier =C3=A9lectronique a =C3=A9t=C3=A9 v=C3=
=A9rifi=C3=A9e par le logiciel antivirus Avast.
https://www.avast.com/antivirus


