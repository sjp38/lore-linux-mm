Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 174836B0005
	for <linux-mm@kvack.org>; Thu, 19 May 2016 19:21:09 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id gw7so134586671pac.0
        for <linux-mm@kvack.org>; Thu, 19 May 2016 16:21:09 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u62si23130574pfi.160.2016.05.19.16.21.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 May 2016 16:21:08 -0700 (PDT)
Date: Thu, 19 May 2016 16:21:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: move page_ext_init after all struct pages are
 initialized
Message-Id: <20160519162107.372d19eac129d590ea160203@linux-foundation.org>
In-Reply-To: <6dd46bac-a0e4-d3c0-ded3-cbacc7f4a4ff@linaro.org>
References: <1463693345-30842-1-git-send-email-yang.shi@linaro.org>
	<20160519153007.322150e4253656a3ac963656@linux-foundation.org>
	<6dd46bac-a0e4-d3c0-ded3-cbacc7f4a4ff@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Shi, Yang" <yang.shi@linaro.org>
Cc: iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

On Thu, 19 May 2016 15:35:15 -0700 "Shi, Yang" <yang.shi@linaro.org> wrote:

> On 5/19/2016 3:30 PM, Andrew Morton wrote:
> > On Thu, 19 May 2016 14:29:05 -0700 Yang Shi <yang.shi@linaro.org> wrote:
> >
> >> When DEFERRED_STRUCT_PAGE_INIT is enabled, just a subset of memmap at boot
> >> are initialized, then the rest are initialized in parallel by starting one-off
> >> "pgdatinitX" kernel thread for each node X.
> >>
> >> If page_ext_init is called before it, some pages will not have valid extension,
> >> so move page_ext_init() after it.
> >>
> >
> > <stdreply>When fixing a bug, please fully describe the end-user impact
> > of that bug</>
> 
> The kernel ran into the below oops which is same with the oops reported 
> in 
> http://ozlabs.org/~akpm/mmots/broken-out/mm-page_is_guard-return-false-when-page_ext-arrays-are-not-allocated-yet.patch.

So this patch makes
mm-page_is_guard-return-false-when-page_ext-arrays-are-not-allocated-yet.patch
obsolete?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
