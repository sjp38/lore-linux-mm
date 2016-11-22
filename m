Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id B02F36B0038
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 11:03:20 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id r101so58291415ioi.3
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 08:03:20 -0800 (PST)
Received: from mail-it0-x242.google.com (mail-it0-x242.google.com. [2607:f8b0:4001:c0b::242])
        by mx.google.com with ESMTPS id 134si3558014itw.6.2016.11.22.08.03.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Nov 2016 08:03:19 -0800 (PST)
Received: by mail-it0-x242.google.com with SMTP id b123so2301632itb.2
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 08:03:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1611091034470.1547@eggly.anvils>
References: <1478271776-1194-1-git-send-email-akash.goel@intel.com>
 <1478271776-1194-2-git-send-email-akash.goel@intel.com> <20161109112835.kivhola7ux3lw4s6@phenom.ffwll.local>
 <alpine.LSU.2.11.1611091034470.1547@eggly.anvils>
From: Matthew Auld <matthew.william.auld@gmail.com>
Date: Tue, 22 Nov 2016 16:02:49 +0000
Message-ID: <CAM0jSHPsD3+sAgK9bqDW3cm-C+PeAb-ojJq2JnEzC--HtyfMGg@mail.gmail.com>
Subject: Re: [Intel-gfx] [PATCH 2/2] drm/i915: Make GPU pages movable
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Daniel Vetter <daniel@ffwll.ch>, Intel Graphics Development <intel-gfx@lists.freedesktop.org>, Sourab Gupta <sourab.gupta@intel.com>, linux-mm@kvack.org, akash.goel@intel.com

On 9 November 2016 at 18:36, Hugh Dickins <hughd@google.com> wrote:
> On Wed, 9 Nov 2016, Daniel Vetter wrote:
>>
>> Hi all -mm folks!
>>
>> Any feedback on these two? It's kinda an intermediate step towards a
>> full-blown gemfs, and I think useful for that. Or do we need to go
>> directly to our own backing storage thing? Aside from ack/nack from -mm I
>> think this is ready for merging.
>
> I'm currently considering them at last: will report back later.
>
> Full-blown gemfs does not come in here, of course; but let me
> fire a warning shot since you mention it: if it's going to use swap,
> then we shall probably have to nak it in favour of continuing to use
> infrastructure from mm/shmem.c.  I very much understand why you would
> love to avoid that dependence, but I doubt it can be safely bypassed.
Could you please elaborate on what specifically you don't like about
gemfs implementing swap, just to make sure I'm following?

Thanks,
Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
