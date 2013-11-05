Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id DC8A76B008A
	for <linux-mm@kvack.org>; Tue,  5 Nov 2013 14:55:57 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id rd3so9435897pab.33
        for <linux-mm@kvack.org>; Tue, 05 Nov 2013 11:55:57 -0800 (PST)
Received: from psmtp.com ([74.125.245.110])
        by mx.google.com with SMTP id gj2si14830275pac.283.2013.11.05.11.55.52
        for <linux-mm@kvack.org>;
        Tue, 05 Nov 2013 11:55:53 -0800 (PST)
Date: Tue, 5 Nov 2013 21:55:51 +0200 (EET)
From: =?UTF-8?B?0JjQstCw0LnQu9C+INCU0LjQvNC40YLRgNC+0LI=?= <freemangordon@abv.bg>
Message-ID: <1380566786.52844.1383681351015.JavaMail.apache@mail83.abv.bg>
Subject: Re: OMAPFB: CMA allocation failures
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tomi Valkeinen <tomi.valkeinen@ti.com>
Cc: minchan@kernel.org, pavel@ucw.cz, sre@debian.org, pali.rohar@gmail.com, pc+n900@asdf.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

 




 >-------- D?N?D,D3D,D 1/2 D?D>>D 1/2 D 3/4  D?D,N?D 1/4 D 3/4  --------
 >D?N?:  Tomi Valkeinen 
 >D?N?D 1/2 D 3/4 N?D 1/2 D 3/4 : Re: OMAPFB: CMA allocation failures
 >D?D 3/4 : D?D2D?D1D>>D 3/4  D?D,D 1/4 D,N?N?D 3/4 D2
 >D?D.D?N?D?N?DuD 1/2 D 3/4  D 1/2 D?: D!N?N?D'D?, 2013, D?DoN?D 3/4 D 1/4 D2N?D, 30 14:19:32 EET
 >
 >I really dislike the idea of adding the omap vram allocator back. Then
 >again, if the CMA doesn't work, something has to be done.
 >

If I got Minchan Kim's explanation correctly, CMA simply can't be used
for allocation of framebuffer memory, because it is unreliable.

 >Pre-allocating is possible, but that won't work if there's any need to
 >re-allocating the framebuffers. Except if the omapfb would retain and
 >manage the pre-allocated buffers, but that would just be more or less
 >the old vram allocator again.
 >
 >So, as I see it, the best option would be to have the standard dma_alloc
 >functions get the memory for omapfb from a private pool, which is not
 >used for anything else.
 >
 >I wonder if that's possible already? It sounds quite trivial to me.
 
dma_alloc functions use either CMA or (iirc) get_pages_exact if CMA is
disabled. Both of those fail easily. AFAIK there are several 
implementations with similar functionality, like CMEM and ION but
(correct me if I am wrong) neither of them is upstreamed. In the 
current kernel I don't see anything that can be used for the purpose 
of reliable allocation of big chunks of contiguous memory.
So, something should be done, but honestly, I can't think of anything
but bringing VRAM allocator back. Not that I like the idea of bringing
back ~700 lines of code, but I see no other option if omapfb driver is
to be actually useful.

Regards,
Ivo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
