Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 1ACD66B004D
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 07:15:10 -0400 (EDT)
Received: by mail-wi0-f171.google.com with SMTP id hi2so5723288wib.16
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 04:15:09 -0700 (PDT)
Received: from mail-wi0-x231.google.com (mail-wi0-x231.google.com [2a00:1450:400c:c05::231])
        by mx.google.com with ESMTPS id g18si26800632wiv.106.2014.07.22.04.15.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Jul 2014 04:15:07 -0700 (PDT)
Received: by mail-wi0-f177.google.com with SMTP id ho1so179536wib.4
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 04:15:07 -0700 (PDT)
Date: Tue, 22 Jul 2014 13:15:16 +0200
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [PATCH v2 00/25] AMDKFD kernel driver
Message-ID: <20140722111515.GJ15237@phenom.ffwll.local>
References: <20140721155851.GB4519@gmail.com>
 <20140721170546.GB15237@phenom.ffwll.local>
 <53CD4DD2.10906@amd.com>
 <CAKMK7uFhvGtxj_d6X=4OBdVSm6cT1-Z-DiTE-FTWMnFjY2uqMQ@mail.gmail.com>
 <53CD5ED9.2040600@amd.com>
 <20140721190306.GB5278@gmail.com>
 <20140722072851.GH15237@phenom.ffwll.local>
 <53CE1E9C.8020105@amd.com>
 <CAKMK7uH+okhn4YGOzrXZ1LM3S2myxdu=_63LGMduwV-WZn06CA@mail.gmail.com>
 <53CE346B.1080601@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53CE346B.1080601@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oded Gabbay <oded.gabbay@amd.com>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>, Jerome Glisse <j.glisse@gmail.com>, Christian =?iso-8859-1?Q?K=F6nig?= <deathsimple@vodafone.de>, David Airlie <airlied@linux.ie>, Alex Deucher <alexdeucher@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, John Bridgman <John.Bridgman@amd.com>, Joerg Roedel <joro@8bytes.org>, Andrew Lewycky <Andrew.Lewycky@amd.com>, Michel =?iso-8859-1?Q?D=E4nzer?= <michel.daenzer@amd.com>, Ben Goz <Ben.Goz@amd.com>, Alexey Skidanov <Alexey.Skidanov@amd.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-mm <linux-mm@kvack.org>, "Sellek, Tom" <Tom.Sellek@amd.com>

On Tue, Jul 22, 2014 at 12:52:43PM +0300, Oded Gabbay wrote:
> On 22/07/14 12:21, Daniel Vetter wrote:
> >On Tue, Jul 22, 2014 at 10:19 AM, Oded Gabbay <oded.gabbay@amd.com> wrote:
> >>>Exactly, just prevent userspace from submitting more. And if you have
> >>>misbehaving userspace that submits too much, reset the gpu and tell it
> >>>that you're sorry but won't schedule any more work.
> >>
> >>I'm not sure how you intend to know if a userspace misbehaves or not. Can
> >>you elaborate ?
> >
> >Well that's mostly policy, currently in i915 we only have a check for
> >hangs, and if userspace hangs a bit too often then we stop it. I guess
> >you can do that with the queue unmapping you've describe in reply to
> >Jerome's mail.
> >-Daniel
> >
> What do you mean by hang ? Like the tdr mechanism in Windows (checks if a
> gpu job takes more than 2 seconds, I think, and if so, terminates the job).

Essentially yes. But we also have some hw features to kill jobs quicker,
e.g. for media workloads.
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
