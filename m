Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 586FF6B028F
	for <linux-mm@kvack.org>; Thu,  1 Oct 2015 07:51:47 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so29310433wic.0
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 04:51:46 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id q1si3277838wif.64.2015.10.01.04.51.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 01 Oct 2015 04:51:46 -0700 (PDT)
Date: Thu, 1 Oct 2015 13:51:05 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 06/25] x86, pkeys: PTE bits for storing protection key
In-Reply-To: <20150928191819.F8EB3C51@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.11.1510011350470.4500@nanos>
References: <20150928191817.035A64E2@viggo.jf.intel.com> <20150928191819.F8EB3C51@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: borntraeger@de.ibm.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@linux.intel.com

On Mon, 28 Sep 2015, Dave Hansen wrote:
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> Previous documentation has referred to these 4 bits as "ignored".
> That means that software could have made use of them.  But, as
> far as I know, the kernel never used them.
> 
> They are still ignored when protection keys is not enabled, so
> they could theoretically still get used for software purposes.
> 
> We also implement "empty" versions so that code that references
> to them can be optimized away by the compiler when the config
> option is not enabled.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
