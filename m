Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id DEF956B0031
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 16:17:36 -0500 (EST)
Received: by mail-lb0-f171.google.com with SMTP id c11so6327512lbj.2
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 13:17:36 -0800 (PST)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id no3si1410160lbb.80.2014.02.11.13.17.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Feb 2014 13:17:34 -0800 (PST)
Date: Tue, 11 Feb 2014 22:17:32 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 0/4] hugetlb: add hugepagesnid= command-line option
Message-ID: <20140211211732.GS11821@two.firstfloor.org>
References: <1392053268-29239-1-git-send-email-lcapitulino@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1392053268-29239-1-git-send-email-lcapitulino@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mtosatti@redhat.com, mgorman@suse.de, aarcange@redhat.com, andi@firstfloor.org, riel@redhat.com

On Mon, Feb 10, 2014 at 12:27:44PM -0500, Luiz Capitulino wrote:
> HugeTLB command-line option hugepages= allows the user to specify how many
> huge pages should be allocated at boot. On NUMA systems, this argument
> automatically distributes huge pages allocation among nodes, which can
> be undesirable.
> 
> The hugepagesnid= option introduced by this commit allows the user
> to specify which NUMA nodes should be used to allocate boot-time HugeTLB
> pages. For example, hugepagesnid=0,2,2G will allocate two 2G huge pages
> from node 0 only. More details on patch 3/4 and patch 4/4.

The syntax seems very confusing. Can you make that more obvious?

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
