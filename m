Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 069ED6B0003
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 12:30:43 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id u43-v6so14843215pgn.4
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 09:30:42 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w19-v6si14758128pgf.197.2018.10.18.09.30.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Oct 2018 09:30:41 -0700 (PDT)
Date: Thu, 18 Oct 2018 18:30:39 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm: get pfn by page_to_pfn() instead of save in
 page->private
Message-ID: <20181018163039.GF18839@dhcp22.suse.cz>
References: <20181018130429.37837-1-richard.weiyang@gmail.com>
 <20181018131504.GC18839@dhcp22.suse.cz>
 <20181018141008.lcyttmp7bb42uigi@master>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181018141008.lcyttmp7bb42uigi@master>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, mgorman@techsingularity.net, linux-mm@kvack.org

On Thu 18-10-18 14:10:08, Wei Yang wrote:
> On Thu, Oct 18, 2018 at 03:15:04PM +0200, Michal Hocko wrote:
> >On Thu 18-10-18 21:04:29, Wei Yang wrote:
> >> This is not necessary to save the pfn to page->private.
> >> 
> >> The pfn could be retrieved by page_to_pfn() directly.
> >
> >Yes it can, but a cursory look at the commit which has introduced this
> >suggests that this is a micro-optimization. Mel would know more of
> >course. There are some memory models where page_to_pfn is close to free.
> >
> >If that is the case I am not really sure it is measurable or worth it.
> >In any case any change to this code should have a proper justification.
> >In other words, is this change really needed? Does it help in any
> >aspect? Possibly readability? The only thing I can guess from this
> >changelog is that you read the code and stumble over this. If that is
> >the case I would recommend asking author for the motivation and
> >potentially add a comment to explain it better rather than shoot a patch
> >rightaway.
> >
> 
> Your are right. I am really willing to understand why we want to use
> this mechanisum.

I am happy to hear that.

> So the correct procedure is to send a mail to the mail list to query the
> reason?

It is certainly better to ask a question than send a patch without a
proper justification. I would also encourage to use git blame to see
which patch has introduced the specific piece of code. Many times it
helps to understand the motivation. I would also encourage to go back to
the mailing list archives and the associate discussion to the specific
patch. In many cases there is Link: tag which can help you to find the
respective discussion.

Thanks!

-- 
Michal Hocko
SUSE Labs
