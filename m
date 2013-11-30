Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id 79B5F6B0035
	for <linux-mm@kvack.org>; Sat, 30 Nov 2013 05:00:28 -0500 (EST)
Received: by mail-we0-f177.google.com with SMTP id p61so10042210wes.36
        for <linux-mm@kvack.org>; Sat, 30 Nov 2013 02:00:27 -0800 (PST)
Received: from mail-ea0-x22f.google.com (mail-ea0-x22f.google.com [2a00:1450:4013:c01::22f])
        by mx.google.com with ESMTPS id uy8si26351002wjc.161.2013.11.30.02.00.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 30 Nov 2013 02:00:27 -0800 (PST)
Received: by mail-ea0-f175.google.com with SMTP id z10so7359227ead.6
        for <linux-mm@kvack.org>; Sat, 30 Nov 2013 02:00:27 -0800 (PST)
Message-ID: <A5506022381E423385022F79B40C6FAB@ivogl>
From: Ivajlo Dimitrov <ivo.g.dimitrov.75@gmail.com>
References: <1847426616.52843.1383681351015.JavaMail.apache@mail83.abv.bg>
Subject: Re: OMAPFB: CMA allocation failures
Date: Sat, 30 Nov 2013 12:00:25 +0200
MIME-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="utf-8";
	reply-type=original
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tomi Valkeinen <tomi.valkeinen@ti.com>
Cc: minchan@kernel.org, pavel@ucw.cz, sre@debian.org, pali.rohar@gmail.com, pc+n900@asdf.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Ping?

----- Original Message ----- 
From: "D?D2D?D1D>>D 3/4  D?D,D 1/4 D,N?N?D 3/4 D2" <freemangordon@abv.bg>
To: "Tomi Valkeinen" <tomi.valkeinen@ti.com>
Cc: <minchan@kernel.org>; <pavel@ucw.cz>; <sre@debian.org>; 
<pali.rohar@gmail.com>; <pc+n900@asdf.org>; <linux-kernel@vger.kernel.org>; 
<linux-mm@kvack.org>
Sent: Tuesday, November 05, 2013 9:55 PM
Subject: Re: OMAPFB: CMA allocation failures


>
>
>
>
>
> >-------- D?N?D,D3D,D 1/2 D?D>>D 1/2 D 3/4  D?D,N?D 1/4 D 3/4  --------
> >D?N?:  Tomi Valkeinen
> >D?N?D 1/2 D 3/4 N?D 1/2 D 3/4 : Re: OMAPFB: CMA allocation failures
> >D?D 3/4 : D?D2D?D1D>>D 3/4  D?D,D 1/4 D,N?N?D 3/4 D2
> >D?D.D?N?D?N?DuD 1/2 D 3/4  D 1/2 D?: D!N?N?D'D?, 2013, D?DoN?D 3/4 D 1/4 D2N?D, 30 14:19:32 EET
> >
> >I really dislike the idea of adding the omap vram allocator back. Then
> >again, if the CMA doesn't work, something has to be done.
> >
>
> If I got Minchan Kim's explanation correctly, CMA simply can't be used
> for allocation of framebuffer memory, because it is unreliable.
>
> >Pre-allocating is possible, but that won't work if there's any need to
> >re-allocating the framebuffers. Except if the omapfb would retain and
> >manage the pre-allocated buffers, but that would just be more or less
> >the old vram allocator again.
> >
> >So, as I see it, the best option would be to have the standard dma_alloc
> >functions get the memory for omapfb from a private pool, which is not
> >used for anything else.
> >
> >I wonder if that's possible already? It sounds quite trivial to me.
>
> dma_alloc functions use either CMA or (iirc) get_pages_exact if CMA is
> disabled. Both of those fail easily. AFAIK there are several
> implementations with similar functionality, like CMEM and ION but
> (correct me if I am wrong) neither of them is upstreamed. In the
> current kernel I don't see anything that can be used for the purpose
> of reliable allocation of big chunks of contiguous memory.
> So, something should be done, but honestly, I can't think of anything
> but bringing VRAM allocator back. Not that I like the idea of bringing
> back ~700 lines of code, but I see no other option if omapfb driver is
> to be actually useful.
>
> Regards,
> Ivo 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
