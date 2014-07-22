Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 902146B0038
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 05:24:20 -0400 (EDT)
Received: by mail-ig0-f170.google.com with SMTP id h3so3999374igd.3
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 02:24:20 -0700 (PDT)
Received: from mail-ig0-x22f.google.com (mail-ig0-x22f.google.com [2607:f8b0:4001:c05::22f])
        by mx.google.com with ESMTPS id il8si35697296igb.32.2014.07.22.02.24.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Jul 2014 02:24:19 -0700 (PDT)
Received: by mail-ig0-f175.google.com with SMTP id uq10so3796687igb.8
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 02:24:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAKMK7uH+okhn4YGOzrXZ1LM3S2myxdu=_63LGMduwV-WZn06CA@mail.gmail.com>
References: <20140720174652.GE3068@gmail.com>
	<53CD0961.4070505@amd.com>
	<53CD17FD.3000908@vodafone.de>
	<20140721152511.GW15237@phenom.ffwll.local>
	<20140721155851.GB4519@gmail.com>
	<20140721170546.GB15237@phenom.ffwll.local>
	<53CD4DD2.10906@amd.com>
	<CAKMK7uFhvGtxj_d6X=4OBdVSm6cT1-Z-DiTE-FTWMnFjY2uqMQ@mail.gmail.com>
	<53CD5ED9.2040600@amd.com>
	<20140721190306.GB5278@gmail.com>
	<20140722072851.GH15237@phenom.ffwll.local>
	<53CE1E9C.8020105@amd.com>
	<CAKMK7uH+okhn4YGOzrXZ1LM3S2myxdu=_63LGMduwV-WZn06CA@mail.gmail.com>
Date: Tue, 22 Jul 2014 11:24:19 +0200
Message-ID: <CAKMK7uFdM_nQfRYv_vQsMTwHL1zrgThBC9dik0Yvhe6c8WO+8Q@mail.gmail.com>
Subject: Re: [PATCH v2 00/25] AMDKFD kernel driver
From: Daniel Vetter <daniel.vetter@ffwll.ch>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oded Gabbay <oded.gabbay@amd.com>
Cc: Jerome Glisse <j.glisse@gmail.com>, =?UTF-8?Q?Christian_K=C3=B6nig?= <deathsimple@vodafone.de>, David Airlie <airlied@linux.ie>, Alex Deucher <alexdeucher@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, John Bridgman <John.Bridgman@amd.com>, Joerg Roedel <joro@8bytes.org>, Andrew Lewycky <Andrew.Lewycky@amd.com>, =?UTF-8?Q?Michel_D=C3=A4nzer?= <michel.daenzer@amd.com>, Ben Goz <Ben.Goz@amd.com>, Alexey Skidanov <Alexey.Skidanov@amd.com>, Evgeny Pinchuk <Evgeny.Pinchuk@amd.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-mm <linux-mm@kvack.org>

On Tue, Jul 22, 2014 at 11:21 AM, Daniel Vetter <daniel.vetter@ffwll.ch> wrote:
> On Tue, Jul 22, 2014 at 10:19 AM, Oded Gabbay <oded.gabbay@amd.com> wrote:
>>> Exactly, just prevent userspace from submitting more. And if you have
>>> misbehaving userspace that submits too much, reset the gpu and tell it
>>> that you're sorry but won't schedule any more work.
>>
>> I'm not sure how you intend to know if a userspace misbehaves or not. Can
>> you elaborate ?
>
> Well that's mostly policy, currently in i915 we only have a check for
> hangs, and if userspace hangs a bit too often then we stop it. I guess
> you can do that with the queue unmapping you've describe in reply to
> Jerome's mail.

Not just graphics, and especially not just graphics from amd. My
experience is that soc designers are _really_ good at stitching
randoms stuff together. So you need to deal with non-radeon drivers
very likely, too.

Also the real problem isn't really the memory sharing - we have
dma-buf already and could add a special mmap flag to make sure it will
work with svm/iommuv2. The problem is synchronization (either with the
new struct fence stuff from Maarten or with android syncpoints or
something like that). And for that to be possible you need to go
through the kernel.
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
