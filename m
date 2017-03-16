Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id A1AF66B0038
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 16:32:30 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id 9so53291464qkk.6
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 13:32:30 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0253.hostedemail.com. [216.40.44.253])
        by mx.google.com with ESMTPS id j63si101983ita.124.2017.03.16.13.32.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 13:32:29 -0700 (PDT)
Message-ID: <1489696343.13953.11.camel@perches.com>
Subject: Re: [PATCH 1/3] mm: page_alloc: Reduce object size by neatening
 printks
From: Joe Perches <joe@perches.com>
Date: Thu, 16 Mar 2017 13:32:23 -0700
In-Reply-To: <20170316105627.GB30508@dhcp22.suse.cz>
References: <cover.1489628459.git.joe@perches.com>
	 <880b3172b67d806082284d80945e4a231a5574bb.1489628459.git.joe@perches.com>
	 <20170316105627.GB30508@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 2017-03-16 at 11:56 +0100, Michal Hocko wrote:
> On Wed 15-03-17 18:43:13, Joe Perches wrote:
> > Function calls with large argument counts cause x86-64 register
> > spilling.  Reducing the number of arguments in a multi-line printk
> > by converting to multiple printks which saves some object code size.
> > 
> > $ size mm/page_alloc.o* (defconfig)
> >    text    data     bss     dec     hex filename
> >   35914	   1699	    628	  38241	   9561	mm/page_alloc.o.new
> >   36018    1699     628   38345    95c9 mm/page_alloc.o.old
> > 
> > Miscellanea:
> > 
> > o Remove line leading spaces from the formerly multi-line printks
> >   commit a25700a53f71 ("mm: show bounce pages in oom killer output")
> >   back in 2007 started the leading space when a single long line
> >   was split into multiple lines but the leading space was likely
> >   mistakenly kept and subsequent commits followed suit.
> > o Align arguments in a few more printks
> 
> This is really hard to review. Could you just drop all the whitespace
> changes please?

It's a single, simple change.  It's IMO trivial to review.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
