Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id E245A82F71
	for <linux-mm@kvack.org>; Thu,  1 Oct 2015 07:02:50 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so27257950wic.1
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 04:02:50 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id ct4si6651750wjb.45.2015.10.01.04.02.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 01 Oct 2015 04:02:49 -0700 (PDT)
Date: Thu, 1 Oct 2015 13:02:09 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 02/25] x86, pkeys: Add Kconfig option
In-Reply-To: <20150928191818.3378A6C9@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.11.1510011301570.4500@nanos>
References: <20150928191817.035A64E2@viggo.jf.intel.com> <20150928191818.3378A6C9@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: borntraeger@de.ibm.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@linux.intel.com

On Mon, 28 Sep 2015, Dave Hansen wrote:

> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> I don't have a strong opinion on whether we need a Kconfig prompt
> or not.  Protection Keys has relatively little code associated
> with it, and it is not a heavyweight feature to keep enabled.
> However, I can imagine that folks would still appreciate being
> able to disable it.
> 
> We will hide the prompt for now.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
