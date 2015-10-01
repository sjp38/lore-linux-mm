Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 08C486B0291
	for <linux-mm@kvack.org>; Thu,  1 Oct 2015 07:54:48 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so24670004wic.0
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 04:54:47 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id bb3si3271085wib.77.2015.10.01.04.54.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 01 Oct 2015 04:54:46 -0700 (PDT)
Date: Thu, 1 Oct 2015 13:54:05 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 07/25] x86, pkeys: new page fault error code bit: PF_PK
In-Reply-To: <20150928191820.BF4CBF05@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.11.1510011351150.4500@nanos>
References: <20150928191817.035A64E2@viggo.jf.intel.com> <20150928191820.BF4CBF05@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: borntraeger@de.ibm.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@linux.intel.com

On Mon, 28 Sep 2015, Dave Hansen wrote:
>  
>  /*
> @@ -916,7 +918,10 @@ static int spurious_fault_check(unsigned
>  
>  	if ((error_code & PF_INSTR) && !pte_exec(*pte))
>  		return 0;
> -
> +	/*
> +	 * Note: We do not do lazy flushing on protection key
> +	 * changes, so no spurious fault will ever set PF_PK.
> +	 */

It might be a bit more clear to have:

   	/* Comment .... */
  	if ((error_code & PF_PK))
  		return 1;

  	return 1;

That way the comment is associated to obviously redundant code, but
it's easier to read, especially if we add some new PF_ thingy after
that.

Other than that:

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
