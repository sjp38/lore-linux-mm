Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 74FED6B000A
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 18:58:31 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id x8-v6so13938837pln.9
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 15:58:31 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f9sor4198287pgq.422.2018.03.26.15.58.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Mar 2018 15:58:30 -0700 (PDT)
Date: Mon, 26 Mar 2018 15:58:28 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] mm/sparse: pass the __highest_present_section_nr +
 1 to alloc_func()
In-Reply-To: <20180326225621.GA79778@WeideMacBook-Pro.local>
Message-ID: <alpine.DEB.2.20.1803261557280.101300@chino.kir.corp.google.com>
References: <20180326081956.75275-1-richard.weiyang@gmail.com> <alpine.DEB.2.20.1803261356380.251389@chino.kir.corp.google.com> <20180326223034.GA78976@WeideMacBook-Pro.local> <alpine.DEB.2.20.1803261546240.99792@chino.kir.corp.google.com>
 <20180326225621.GA79778@WeideMacBook-Pro.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: dave.hansen@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com, linux-mm@kvack.org

On Tue, 27 Mar 2018, Wei Yang wrote:

> >Lol.  I think it would make more sense for the second patch to come before 
> >the first
> 
> Thanks for your comment.
> 
> Do I need to reorder the patch and send v2?
> 

I think we can just ask Andrew to apply backwards, but it's not crucial.  
The ordering of patch 2 before patch 1 simply helped me to understand the 
boundaries better.
