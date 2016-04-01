Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 107416B007E
	for <linux-mm@kvack.org>; Fri,  1 Apr 2016 18:57:49 -0400 (EDT)
Received: by mail-pf0-f180.google.com with SMTP id n5so100363527pfn.2
        for <linux-mm@kvack.org>; Fri, 01 Apr 2016 15:57:49 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id oz1si9852900pac.46.2016.04.01.15.57.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Apr 2016 15:57:48 -0700 (PDT)
Date: Fri, 1 Apr 2016 15:57:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] mm: Real pagecache iterators
Message-Id: <20160401155747.249e0f8ed89e00fbb24111d2@linux-foundation.org>
In-Reply-To: <1459478291-29982-2-git-send-email-kent.overstreet@gmail.com>
References: <20160401023510.GA28762@kmo-pixel>
	<1459478291-29982-1-git-send-email-kent.overstreet@gmail.com>
	<1459478291-29982-2-git-send-email-kent.overstreet@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kent Overstreet <kent.overstreet@gmail.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 31 Mar 2016 18:38:11 -0800 Kent Overstreet <kent.overstreet@gmail.com> wrote:

> Introduce for_each_pagecache_page() and related macros, with the goal of
> replacing most/all uses of pagevec_lookup().
> 
> For the most part this shouldn't be a functional change. The one functional
> difference with the new macros is that they now take an @end parameter, so we're
> able to avoid grabbing pages in __find_get_pages() that we'll never use.
> 
> This patch only does some of the conversions, the ones I was able to easily test
> myself - the conversions are mechanical but tricky enough they generally warrent
> testing.

What is the reason for this change?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
