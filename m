Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id A47C382F71
	for <linux-mm@kvack.org>; Thu,  1 Oct 2015 07:03:59 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so24082681wic.0
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 04:03:59 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id ds10si3021057wib.120.2015.10.01.04.03.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 01 Oct 2015 04:03:58 -0700 (PDT)
Date: Thu, 1 Oct 2015 13:03:18 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 04/25] x86, pku: define new CR4 bit
In-Reply-To: <20150928191818.EDCB3BED@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.11.1510011303070.4500@nanos>
References: <20150928191817.035A64E2@viggo.jf.intel.com> <20150928191818.EDCB3BED@viggo.jf.intel.com>
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
> There is a new bit in CR4 for enabling protection keys.  We
> will actually enable it later in the series.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
