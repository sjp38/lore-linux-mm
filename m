Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f180.google.com (mail-ie0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 1C62A6B0035
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 05:21:14 -0400 (EDT)
Received: by mail-ie0-f180.google.com with SMTP id at20so7602632iec.25
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 02:21:13 -0700 (PDT)
Received: from mail-ie0-x231.google.com (mail-ie0-x231.google.com [2607:f8b0:4001:c03::231])
        by mx.google.com with ESMTPS id um8si397581icb.69.2014.07.22.02.21.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Jul 2014 02:21:12 -0700 (PDT)
Received: by mail-ie0-f177.google.com with SMTP id at20so7496204iec.8
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 02:21:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53CE1E9C.8020105@amd.com>
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
Date: Tue, 22 Jul 2014 11:21:12 +0200
Message-ID: <CAKMK7uH+okhn4YGOzrXZ1LM3S2myxdu=_63LGMduwV-WZn06CA@mail.gmail.com>
Subject: Re: [PATCH v2 00/25] AMDKFD kernel driver
From: Daniel Vetter <daniel.vetter@ffwll.ch>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oded Gabbay <oded.gabbay@amd.com>
Cc: Jerome Glisse <j.glisse@gmail.com>, =?UTF-8?Q?Christian_K=C3=B6nig?= <deathsimple@vodafone.de>, David Airlie <airlied@linux.ie>, Alex Deucher <alexdeucher@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, John Bridgman <John.Bridgman@amd.com>, Joerg Roedel <joro@8bytes.org>, Andrew Lewycky <Andrew.Lewycky@amd.com>, =?UTF-8?Q?Michel_D=C3=A4nzer?= <michel.daenzer@amd.com>, Ben Goz <Ben.Goz@amd.com>, Alexey Skidanov <Alexey.Skidanov@amd.com>, Evgeny Pinchuk <Evgeny.Pinchuk@amd.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-mm <linux-mm@kvack.org>

On Tue, Jul 22, 2014 at 10:19 AM, Oded Gabbay <oded.gabbay@amd.com> wrote:
>> Exactly, just prevent userspace from submitting more. And if you have
>> misbehaving userspace that submits too much, reset the gpu and tell it
>> that you're sorry but won't schedule any more work.
>
> I'm not sure how you intend to know if a userspace misbehaves or not. Can
> you elaborate ?

Well that's mostly policy, currently in i915 we only have a check for
hangs, and if userspace hangs a bit too often then we stop it. I guess
you can do that with the queue unmapping you've describe in reply to
Jerome's mail.
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
