Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f179.google.com (mail-ea0-f179.google.com [209.85.215.179])
	by kanga.kvack.org (Postfix) with ESMTP id 021E46B0099
	for <linux-mm@kvack.org>; Thu, 20 Feb 2014 11:08:33 -0500 (EST)
Received: by mail-ea0-f179.google.com with SMTP id q10so1018060ead.10
        for <linux-mm@kvack.org>; Thu, 20 Feb 2014 08:08:33 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id p44si9539663eeu.215.2014.02.20.08.08.30
        for <linux-mm@kvack.org>;
        Thu, 20 Feb 2014 08:08:32 -0800 (PST)
Date: Thu, 20 Feb 2014 10:06:03 -0500
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH 4/4] hugetlb: add hugepages_node= command-line option
Message-ID: <20140220100603.76622b33@redhat.com>
In-Reply-To: <alpine.DEB.2.02.1402192048240.2568@chino.kir.corp.google.com>
References: <1392339728-13487-1-git-send-email-lcapitulino@redhat.com>
 <1392339728-13487-5-git-send-email-lcapitulino@redhat.com>
 <alpine.DEB.2.02.1402141511200.13935@chino.kir.corp.google.com>
 <20140214225810.57e854cb@redhat.com>
 <alpine.DEB.2.02.1402150159540.28883@chino.kir.corp.google.com>
 <20140217085622.39b39cac@redhat.com>
 <alpine.DEB.2.02.1402171518080.25724@chino.kir.corp.google.com>
 <20140218123013.GA20609@amt.cnet>
 <alpine.DEB.2.02.1402181407510.20772@chino.kir.corp.google.com>
 <20140220022254.GA25898@amt.cnet>
 <alpine.DEB.2.02.1402191941330.29913@chino.kir.corp.google.com>
 <20140219234232.07dc1eab@redhat.com>
 <alpine.DEB.2.02.1402192048240.2568@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, davidlohr@hp.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 19 Feb 2014 20:51:55 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Wed, 19 Feb 2014, Luiz Capitulino wrote:
> 
> > > Yes, my concrete objection is that the command line interface is 
> > > unnecessary if you can dynamically allocate and free 1GB pages at runtime 
> > > unless memory will be so fragmented that it cannot be done when userspace 
> > > is brought up.  That is not your use case, thus this support is not 
> > 
> > Yes it is. The early boot is the most reliable moment to allocate huge pages
> > and we want to take advantage from that.
> > 
> 
> Your use case is 8GB of hugepages on a 32GB machine.  It shouldn't be 
> necessary to do that at boot.

That's shortsighted because it's tied to a particular machine. The same
customer asked for more flexibility, too.

Look, we're also looking forward to allocating 1G huge pages from user-space.
We actually agree here. What we're suggesting is having _both_, the
command-line option (which offers higher reliability and is a low hanging
fruit right now) _and_ later we add support to allocate 1G huge pages from
user-space. No loss here, that's the maximum benefit for all users.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
