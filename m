Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id AE12A6B0035
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 03:31:13 -0500 (EST)
Received: by mail-wi0-f170.google.com with SMTP id hq4so632446wib.1
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 00:31:12 -0800 (PST)
Received: from mail-ea0-x22b.google.com (mail-ea0-x22b.google.com [2a00:1450:4013:c01::22b])
        by mx.google.com with ESMTPS id r2si813569wix.40.2013.12.06.00.31.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 06 Dec 2013 00:31:12 -0800 (PST)
Received: by mail-ea0-f171.google.com with SMTP id h10so141192eak.16
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 00:31:12 -0800 (PST)
Message-ID: <52A18B4F.1070809@gmail.com>
Date: Fri, 06 Dec 2013 10:31:11 +0200
From: Ivajlo Dimitrov <ivo.g.dimitrov.75@gmail.com>
MIME-Version: 1.0
Subject: Re: OMAPFB: CMA allocation failures
References: <1847426616.52843.1383681351015.JavaMail.apache@mail83.abv.bg> <A5506022381E423385022F79B40C6FAB@ivogl> <52A062A0.3070005@ti.com>
In-Reply-To: <52A062A0.3070005@ti.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tomi Valkeinen <tomi.valkeinen@ti.com>
Cc: minchan@kernel.org, pavel@ucw.cz, sre@debian.org, pali.rohar@gmail.com, pc+n900@asdf.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org


On 05.12.2013 13:25, Tomi Valkeinen wrote:
> How about the patch below? If I'm not mistaken (and I might) it reserves
> separate memory area for omapfb, which is not used by CMA.
>
> If it works, it should be extended to get the parameters via kernel
> cmdline, and use that alloc only if the user requests it.
>

YAY!!! That one seems to fix the issue.

Though I had to revert 7faa92339bbb1e6b9a80983b206642517327eb75 (well, I 
hacked check_horiz_timing_omap3 to always return 0). Otherwise I have 
"omapdss DISPC error: horizontal timing too tight" error when try to 
play anything above 320x240 or so. I'll look at the issue.

Regards,
Ivo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
