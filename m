Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id 5D26D6B005A
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 17:32:06 -0400 (EDT)
Received: by mail-we0-f180.google.com with SMTP id k48so59794wev.11
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 14:32:05 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id n17si24735wiv.20.2014.04.22.14.32.03
        for <linux-mm@kvack.org>;
        Tue, 22 Apr 2014 14:32:04 -0700 (PDT)
Message-ID: <5356DFC8.1060601@redhat.com>
Date: Tue, 22 Apr 2014 17:31:52 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/6] x86: mm: new tunable for single vs full TLB flush
References: <20140421182418.81CF7519@viggo.jf.intel.com> <20140421182426.D6DD1E8F@viggo.jf.intel.com>
In-Reply-To: <20140421182426.D6DD1E8F@viggo.jf.intel.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>, x86@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mgorman@suse.de, ak@linux.intel.com, alex.shi@linaro.org, dave.hansen@linux.intel.com

On 04/21/2014 02:24 PM, Dave Hansen wrote:
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> Most of the logic here is in the documentation file.  Please take
> a look at it.
> 
> I know we've come full-circle here back to a tunable, but this
> new one is *WAY* simpler.  I challenge anyone to describe in one
> sentence how the old one worked.  Here's the way the new one
> works:
> 
> 	If we are flushing more pages than the ceiling, we use
> 	the full flush, otherwise we use per-page flushes.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

Acked-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
