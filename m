Received: from mail.ccr.net (ccr@alogconduit1af.ccr.net [208.130.159.6])
	by kvack.org (8.8.7/8.8.7) with ESMTP id TAA27660
	for <linux-mm@kvack.org>; Sun, 27 Dec 1998 19:52:40 -0500
Subject: Re: Large-File support of 32-bit Linux v0.01 available!
References: <19981227220446Z92289-18655+40@mea.tmt.tele.fi>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 27 Dec 1998 19:01:25 -0600
In-Reply-To: Matti Aarnio's message of "Mon, 28 Dec 1998 00:04:37 +0200 (EET)"
Message-ID: <m1ww3d3wre.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Matti Aarnio <matti.aarnio@sonera.fi>
Cc: "Eric W. Biederman" <ebiederm+eric@ccr.net>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

>>>>> "MA" == Matti Aarnio <matti.aarnio@sonera.fi> writes:

>> I have some other logic mostly complete that keeps offset parameter in
>> the vm_area struct at 32 bits, and hopefully a greater chunck of the
>> page cache.

MA> 	You mean 'vm_offset' field ?
MA> 	There are 37 files with (sub)string 'vm_offset' in them.
MA> 	Changeing its type from current  loff_t  to  pgoff_t  would
MA> 	help finding its instances, I guess.  (And thus ease locating
MA> 	places using it for page (non-)aligned things.)

I changed the name from vm_offset to vm_index.  Works equally well.

As far as non page alinged things, the only instance I have heard of
to date was with a.out.

There are a lot of implications to changing vm_offset in filemap.c
that I'm just finishing working out.

That and putting tests to see if the file size is bigger than we can
handle in the page cache at approprate places.

I believe I started at the really efficient end and you started at the
functional end.

Makes life fun . . .

MA> 	That part about "a greater chunk" I don't understand, though.

Poorly worded, (Thinking to fast probably!)

My meaning was changing the meaning of vm_offset you remove potential
64bit calculations from a lot of places.

Eric

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
