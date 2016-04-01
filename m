Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id E1FAB6B007E
	for <linux-mm@kvack.org>; Fri,  1 Apr 2016 19:20:27 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id td3so100719144pab.2
        for <linux-mm@kvack.org>; Fri, 01 Apr 2016 16:20:27 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id f90si8368787pfd.94.2016.04.01.16.20.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Apr 2016 16:20:27 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id x3so15213676pfb.0
        for <linux-mm@kvack.org>; Fri, 01 Apr 2016 16:20:27 -0700 (PDT)
Date: Fri, 1 Apr 2016 15:20:21 -0800
From: Kent Overstreet <kent.overstreet@gmail.com>
Subject: Re: [PATCH 2/2] mm: Real pagecache iterators
Message-ID: <20160401232021.GA16071@kmo-pixel>
References: <20160401023510.GA28762@kmo-pixel>
 <1459478291-29982-1-git-send-email-kent.overstreet@gmail.com>
 <1459478291-29982-2-git-send-email-kent.overstreet@gmail.com>
 <20160401155747.249e0f8ed89e00fbb24111d2@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160401155747.249e0f8ed89e00fbb24111d2@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Apr 01, 2016 at 03:57:47PM -0700, Andrew Morton wrote:
> On Thu, 31 Mar 2016 18:38:11 -0800 Kent Overstreet <kent.overstreet@gmail.com> wrote:
> 
> > Introduce for_each_pagecache_page() and related macros, with the goal of
> > replacing most/all uses of pagevec_lookup().
> > 
> > For the most part this shouldn't be a functional change. The one functional
> > difference with the new macros is that they now take an @end parameter, so we're
> > able to avoid grabbing pages in __find_get_pages() that we'll never use.
> > 
> > This patch only does some of the conversions, the ones I was able to easily test
> > myself - the conversions are mechanical but tricky enough they generally warrent
> > testing.
> 
> What is the reason for this change?

I just got tired of code being hard to follow when I was trying to work on some
pagecache invalidation stuff.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
