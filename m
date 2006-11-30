Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id kAUBPVXP001889
	for <linux-mm@kvack.org>; Thu, 30 Nov 2006 03:25:33 -0800
Received: from nf-out-0910.google.com (nfbc31.prod.google.com [10.48.79.31])
	by zps75.corp.google.com with ESMTP id kAUBOvuN027105
	for <linux-mm@kvack.org>; Thu, 30 Nov 2006 03:25:21 -0800
Received: by nf-out-0910.google.com with SMTP id c31so4992930nfb
        for <linux-mm@kvack.org>; Thu, 30 Nov 2006 03:25:21 -0800 (PST)
Message-ID: <6599ad830611300325h3269a185x5794b0c585d985c0@mail.gmail.com>
Date: Thu, 30 Nov 2006 03:25:21 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][PATCH 0/1] Node-based reclaim/migration
In-Reply-To: <20061130201232.7d5f5578.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20061129030655.941148000@menage.corp.google.com>
	 <20061130093105.d872c49d.kamezawa.hiroyu@jp.fujitsu.com>
	 <6599ad830611291631hd6d3e52y971c35708004db00@mail.gmail.com>
	 <Pine.LNX.4.64.0611292015280.19628@schroedinger.engr.sgi.com>
	 <6599ad830611300245s5c0f40bdu4231832930e9c023@mail.gmail.com>
	 <20061130201232.7d5f5578.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: clameter@sgi.com, linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On 11/30/06, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> > How does kswapd do this safely?
> >
> kswapd doesn't touches page->mapping after page_mapcount() goes down to 0.

OK, so we could do the same, and just assume that pages with a
page_mapcount() of 0 are either about to be freed or can be picked up
on a later migration sweep. Is it common for a page to have a 0
page_mapcount() for a long period of time without being freed or
remapped?

>
> I think one of the biggest concern will be performance impact. And this will
> touch objrmap core, it is good to start discussion with a patch.
>

I'll have a go. My initial thought is that the only performance impact
on the rmap core would be that unlink_anon_vma() would need one extra
check when determining whether to free an anon_vma

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
