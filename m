Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 0EBBF6B0005
	for <linux-mm@kvack.org>; Thu,  7 Apr 2016 22:31:54 -0400 (EDT)
Received: by mail-wm0-f42.google.com with SMTP id u206so5205870wme.1
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 19:31:54 -0700 (PDT)
Received: from mail-wm0-x22b.google.com (mail-wm0-x22b.google.com. [2a00:1450:400c:c09::22b])
        by mx.google.com with ESMTPS id m194si742268wmg.82.2016.04.07.19.31.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Apr 2016 19:31:52 -0700 (PDT)
Received: by mail-wm0-x22b.google.com with SMTP id l6so47523180wml.1
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 19:31:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160407231413.53e371ff@redhat.com>
References: <1459971348-81477-1-git-send-email-thgarnie@google.com>
	<CAGXu5jLEENTFL_NYA5r4SqmUefkEwL68_Br6bX_RY2xNv95GVg@mail.gmail.com>
	<20160407231413.53e371ff@redhat.com>
Date: Thu, 7 Apr 2016 19:31:52 -0700
Message-ID: <CAGXu5j+4AJ_TMKus=bwWdK9+xBgWF44gHxcu5Bagw5ApB3Eg0A@mail.gmail.com>
Subject: Re: [RFC v1] mm: SLAB freelist randomization
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Thomas Garnier <thgarnie@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Laura Abbott <labbott@fedoraproject.org>

On Thu, Apr 7, 2016 at 2:14 PM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
>
> On Wed, 6 Apr 2016 14:45:30 -0700 Kees Cook <keescook@chromium.org> wrote:
>
>> On Wed, Apr 6, 2016 at 12:35 PM, Thomas Garnier <thgarnie@google.com> wrote:
> [...]
>> > re-used on slab creation for performance.
>>
>> I'd like to see some benchmark results for this so the Kconfig can
>> include the performance characteristics. I recommend using hackbench
>> and kernel build times with a before/after comparison.
>>
>
> It looks like it only happens on init, right? (Thus must bench tools
> might not be the right choice).

Oh! Yes, you're right. I entirely missed that detail. :) 0-cost
randomization! Sounds good to me. :)

-Kees

>
> My slab tools for benchmarking the fastpath is here:
>  https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/mm/slab_bulk_test01.c
>
> And I also carry a version of Christoph's slab bench tool:
>  https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/mm/slab_test.c
>
> --
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Principal Kernel Engineer at Red Hat
>   Author of http://www.iptv-analyzer.org
>   LinkedIn: http://www.linkedin.com/in/brouer



-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
