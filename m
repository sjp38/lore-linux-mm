Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 1F6846B0031
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 23:02:00 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id rd3so8622235pab.30
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 20:01:59 -0800 (PST)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id ay1si21160315pbd.126.2014.02.11.20.01.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 11 Feb 2014 20:01:59 -0800 (PST)
Received: by mail-pa0-f47.google.com with SMTP id kp14so8616486pab.34
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 20:01:58 -0800 (PST)
Date: Tue, 11 Feb 2014 20:01:43 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 0/4] hugetlb: add hugepagesnid= command-line option
In-Reply-To: <20140212023711.GT11821@two.firstfloor.org>
Message-ID: <alpine.DEB.2.02.1402112000000.31912@chino.kir.corp.google.com>
References: <1392053268-29239-1-git-send-email-lcapitulino@redhat.com> <20140211211732.GS11821@two.firstfloor.org> <20140211163108.3136d55a@redhat.com> <20140212023711.GT11821@two.firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Luiz Capitulino <lcapitulino@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mtosatti@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com

On Wed, 12 Feb 2014, Andi Kleen wrote:

> > The real syntax is hugepagesnid=nid,nr-pages,size. Which looks straightforward
> > to me. I honestly can't think of anything better than that, but I'm open for
> > suggestions.
> 
> hugepages_node=nid:nr-pages:size,... ? 
> 

I think that if we actually want this support that it should behave like 
hugepages= and hugepagesz=, i.e. you specify a hugepagesnode= and, if 
present, all remaining hugepages= and hugepagesz= parameters act only on 
that node unless overridden by another hugepagesnode=.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
