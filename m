Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 658766B0069
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 07:57:40 -0400 (EDT)
Date: Fri, 5 Oct 2012 13:57:31 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 0/8] THP support for Sparc64
Message-ID: <20121005115731.GI6793@redhat.com>
References: <20121002155544.2c67b1e8.akpm@linux-foundation.org>
 <20121003.220027.1636081487098835868.davem@davemloft.net>
 <20121004103548.GB6793@redhat.com>
 <20121004.141136.1763670567147718953.davem@davemloft.net>
 <20121005092810.GA27763@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121005092810.GA27763@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, hannes@cmpxchg.org, gerald.schaefer@de.ibm.com

Hi Michal,

On Fri, Oct 05, 2012 at 11:28:10AM +0200, Michal Hocko wrote:
> FWIW there is also a pure -mm (non-rebased) git tree at
> http://git.kernel.org/?p=linux/kernel/git/mhocko/mm.git;a=summary
> since-3.6 branch. It is based on top of 3.6 with mm patches from
> Andrew's tree.

I'd still suggest to use your mm.git tree to rebase the -mm patches,
until schednuma will be dropped from linux-next. Either that or I hope
you don't run any benchmark with more than one NUMA node.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
