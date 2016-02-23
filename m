Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f43.google.com (mail-lf0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id BAB4A828DF
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 10:30:09 -0500 (EST)
Received: by mail-lf0-f43.google.com with SMTP id m1so118633794lfg.0
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 07:30:09 -0800 (PST)
Received: from mail-lf0-x22f.google.com (mail-lf0-x22f.google.com. [2a00:1450:4010:c07::22f])
        by mx.google.com with ESMTPS id o70si16037610lfe.74.2016.02.23.07.30.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 07:30:08 -0800 (PST)
Received: by mail-lf0-x22f.google.com with SMTP id j78so117511173lfb.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 07:30:08 -0800 (PST)
Date: Tue, 23 Feb 2016 16:30:03 +0100
From: Rabin Vincent <rabin@rab.in>
Subject: Re: [PATCH 2/2] ARM: dma-mapping: fix alloc/free for coherent + CMA
 + gfp=0
Message-ID: <20160223153003.GB22447@lnxrabinv.se.axis.com>
References: <1455869524-13874-1-git-send-email-rabin.vincent@axis.com>
 <1455869524-13874-2-git-send-email-rabin.vincent@axis.com>
 <xa1tio1kzu4j.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <xa1tio1kzu4j.fsf@mina86.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Rabin Vincent <rabin.vincent@axis.com>, linux@arm.linux.org.uk, akpm@linux-foundation.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Feb 19, 2016 at 02:50:52PM +0100, Michal Nazarewicz wrote:
> I havena??t looked closely at the code, but why not:
> 
> 	struct cma *cma = 
>         if (!cma_release(dev_get_cma_area(dev), page, size >> PAGE_SHIFT)) {
> 		// ... do whatever other non-CMA free
> 	}

The page tables changes need to be done before we release the area with
cma_release().  With the v2 patchset which I've sent to LAKML we won't
need a new in_cma() function since we'll now record how we allocated the
buffer and use this information in the free routine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
