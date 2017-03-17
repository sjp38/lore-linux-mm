Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id D32AE6B0038
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 03:39:47 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id l37so12281579wrc.7
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 00:39:47 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x133si2121238wme.3.2017.03.17.00.39.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Mar 2017 00:39:46 -0700 (PDT)
Date: Fri, 17 Mar 2017 08:39:44 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] mm: page_alloc: Reduce object size by neatening
 printks
Message-ID: <20170317073943.GA26298@dhcp22.suse.cz>
References: <cover.1489628459.git.joe@perches.com>
 <880b3172b67d806082284d80945e4a231a5574bb.1489628459.git.joe@perches.com>
 <20170316105627.GB30508@dhcp22.suse.cz>
 <1489696343.13953.11.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1489696343.13953.11.camel@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 16-03-17 13:32:23, Joe Perches wrote:
> On Thu, 2017-03-16 at 11:56 +0100, Michal Hocko wrote:
> > On Wed 15-03-17 18:43:13, Joe Perches wrote:
> > > Function calls with large argument counts cause x86-64 register
> > > spilling.  Reducing the number of arguments in a multi-line printk
> > > by converting to multiple printks which saves some object code size.
> > > 
> > > $ size mm/page_alloc.o* (defconfig)
> > >    text    data     bss     dec     hex filename
> > >   35914	   1699	    628	  38241	   9561	mm/page_alloc.o.new
> > >   36018    1699     628   38345    95c9 mm/page_alloc.o.old
> > > 
> > > Miscellanea:
> > > 
> > > o Remove line leading spaces from the formerly multi-line printks
> > >   commit a25700a53f71 ("mm: show bounce pages in oom killer output")
> > >   back in 2007 started the leading space when a single long line
> > >   was split into multiple lines but the leading space was likely
> > >   mistakenly kept and subsequent commits followed suit.
> > > o Align arguments in a few more printks
> > 
> > This is really hard to review. Could you just drop all the whitespace
> > changes please?
> 
> It's a single, simple change. 

no it adds a lot of whitespace noise to an actual change. It takes to
check every single line to see whether some typo or unintended change
has been made.

> It's IMO trivial to review.

it's not IMNSHO.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
