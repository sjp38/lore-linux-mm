Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f180.google.com (mail-gg0-f180.google.com [209.85.161.180])
	by kanga.kvack.org (Postfix) with ESMTP id 515686B0031
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 21:37:50 -0500 (EST)
Received: by mail-gg0-f180.google.com with SMTP id q3so344514gge.11
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 18:37:50 -0800 (PST)
Received: from mail-yh0-x22b.google.com (mail-yh0-x22b.google.com [2607:f8b0:4002:c01::22b])
        by mx.google.com with ESMTPS id n44si3160882yhn.140.2014.01.14.18.37.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 14 Jan 2014 18:37:49 -0800 (PST)
Received: by mail-yh0-f43.google.com with SMTP id a41so375006yho.16
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 18:37:49 -0800 (PST)
Date: Tue, 14 Jan 2014 18:37:45 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC][PATCH 2/9] mm: slub: abstract out double cmpxchg option
In-Reply-To: <52D5AEF7.6020707@sr71.net>
Message-ID: <alpine.DEB.2.02.1401141832420.32645@chino.kir.corp.google.com>
References: <20140114180042.C1C33F78@viggo.jf.intel.com> <20140114180046.C897727E@viggo.jf.intel.com> <alpine.DEB.2.10.1401141346310.19618@nuc> <52D5AEF7.6020707@sr71.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, penberg@kernel.org

On Tue, 14 Jan 2014, Dave Hansen wrote:

> > On Tue, 14 Jan 2014, Dave Hansen wrote:
> >> I found this useful to have in my testing.  I would like to have
> >> it available for a bit, at least until other folks have had a
> >> chance to do some testing with it.
> > 
> > I dont really see the point of this patch since we already have
> > CONFIG_HAVE_ALIGNED_STRUCT_PAGE to play with.
> 
> With the current code, if you wanted to turn off the double-cmpxchg abd
> get a 56-byte 'struct page' how would you do it?  Can you do it with a
> .config, or do you need to hack the code?
> 

If that's the intention of disabling this new config option, then it 
should probably mention the savings in the "help" section, similar to what
CONFIG_HAVE_ALIGNED_STRUCT_PAGE says.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
