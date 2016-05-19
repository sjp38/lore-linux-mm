Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 980196B0005
	for <linux-mm@kvack.org>; Thu, 19 May 2016 18:30:09 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id gw7so133129506pac.0
        for <linux-mm@kvack.org>; Thu, 19 May 2016 15:30:09 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id hx8si22847395pac.95.2016.05.19.15.30.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 May 2016 15:30:08 -0700 (PDT)
Date: Thu, 19 May 2016 15:30:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: move page_ext_init after all struct pages are
 initialized
Message-Id: <20160519153007.322150e4253656a3ac963656@linux-foundation.org>
In-Reply-To: <1463693345-30842-1-git-send-email-yang.shi@linaro.org>
References: <1463693345-30842-1-git-send-email-yang.shi@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linaro.org>
Cc: iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

On Thu, 19 May 2016 14:29:05 -0700 Yang Shi <yang.shi@linaro.org> wrote:

> When DEFERRED_STRUCT_PAGE_INIT is enabled, just a subset of memmap at boot
> are initialized, then the rest are initialized in parallel by starting one-off
> "pgdatinitX" kernel thread for each node X.
> 
> If page_ext_init is called before it, some pages will not have valid extension,
> so move page_ext_init() after it.
> 

<stdreply>When fixing a bug, please fully describe the end-user impact
of that bug</>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
