Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id CD7266B0035
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 20:22:06 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id hz1so160498pad.6
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 17:22:06 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id xa3si3578585pab.24.2014.08.27.17.22.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Aug 2014 17:22:05 -0700 (PDT)
Date: Wed, 27 Aug 2014 17:21:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] x86: Optimize resource lookups for ioremap
Message-Id: <20140827172128.93feef68.akpm@linux-foundation.org>
In-Reply-To: <53FE6FAA.6010806@sgi.com>
References: <20140827225927.364537333@asylum.americas.sgi.com>
	<20140827225927.602319674@asylum.americas.sgi.com>
	<20140827160515.c59f1c191fde5f788a7c42f6@linux-foundation.org>
	<53FE6515.6050102@sgi.com>
	<20140827161854.0619a04653b336d3adc755f3@linux-foundation.org>
	<53FE68E4.4090902@sgi.com>
	<20140827163745.774e9b5c591e8f9cf7542a4d@linux-foundation.org>
	<53FE6FAA.6010806@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: mingo@redhat.com, tglx@linutronix.de, hpa@zytor.com, msalter@redhat.com, dyoung@redhat.com, riel@redhat.com, peterz@infradead.org, mgorman@suse.de, linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, Alex Thorlton <athorlton@sgi.com>

On Wed, 27 Aug 2014 16:54:18 -0700 Mike Travis <travis@sgi.com> wrote:

> > If we're still at 1+ hours then little bodges like this are nowhere
> > near sufficient and sterner stuff will be needed.
> > 
> > Do we actually need the test?  My googling turns up zero instances of
> > anyone reporting the "ioremap on RAM pfn" warning.
> 
> We get them more than we like, mostly from 3rd party vendors, and
> esp. those that merely port their windows drivers to linux.

Dang.  So wrapping the check in CONFIG_DEBUG_VM would be problematic?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
