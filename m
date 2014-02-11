Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f175.google.com (mail-ea0-f175.google.com [209.85.215.175])
	by kanga.kvack.org (Postfix) with ESMTP id 654006B0031
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 16:31:26 -0500 (EST)
Received: by mail-ea0-f175.google.com with SMTP id n15so1224992ead.20
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 13:31:25 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id g47si34611755eev.90.2014.02.11.13.31.24
        for <linux-mm@kvack.org>;
        Tue, 11 Feb 2014 13:31:24 -0800 (PST)
Date: Tue, 11 Feb 2014 16:31:08 -0500
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH 0/4] hugetlb: add hugepagesnid= command-line option
Message-ID: <20140211163108.3136d55a@redhat.com>
In-Reply-To: <20140211211732.GS11821@two.firstfloor.org>
References: <1392053268-29239-1-git-send-email-lcapitulino@redhat.com>
	<20140211211732.GS11821@two.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mtosatti@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com

On Tue, 11 Feb 2014 22:17:32 +0100
Andi Kleen <andi@firstfloor.org> wrote:

> On Mon, Feb 10, 2014 at 12:27:44PM -0500, Luiz Capitulino wrote:
> > HugeTLB command-line option hugepages= allows the user to specify how many
> > huge pages should be allocated at boot. On NUMA systems, this argument
> > automatically distributes huge pages allocation among nodes, which can
> > be undesirable.
> > 
> > The hugepagesnid= option introduced by this commit allows the user
> > to specify which NUMA nodes should be used to allocate boot-time HugeTLB
> > pages. For example, hugepagesnid=0,2,2G will allocate two 2G huge pages
> > from node 0 only. More details on patch 3/4 and patch 4/4.
> 
> The syntax seems very confusing. Can you make that more obvious?

I guess that my bad description in this email may have contributed to make
it look confusing.

The real syntax is hugepagesnid=nid,nr-pages,size. Which looks straightforward
to me. I honestly can't think of anything better than that, but I'm open for
suggestions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
