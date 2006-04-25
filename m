Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.6/8.13.6) with ESMTP id k3PAiNtw045828
	for <linux-mm@kvack.org>; Tue, 25 Apr 2006 10:44:23 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k3PAjSKp114940
	for <linux-mm@kvack.org>; Tue, 25 Apr 2006 12:45:28 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id k3PAiMBV009402
	for <linux-mm@kvack.org>; Tue, 25 Apr 2006 12:44:23 +0200
Subject: Re: Page host virtual assist patches.
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
In-Reply-To: <20060425013712.365892c2.akpm@osdl.org>
References: <20060424123412.GA15817@skybase>
	 <20060424180138.52e54e5c.akpm@osdl.org> <444DCD87.2030307@yahoo.com.au>
	 <1145953914.5282.21.camel@localhost>
	 <20060425013712.365892c2.akpm@osdl.org>
Content-Type: text/plain
Date: Tue, 25 Apr 2006 12:44:27 +0200
Message-Id: <1145961867.5282.46.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: nickpiggin@yahoo.com.au, linux-mm@kvack.org, frankeh@watson.ibm.com, rhim@cc.gatech.edu
List-ID: <linux-mm.kvack.org>

On Tue, 2006-04-25 at 01:37 -0700, Andrew Morton wrote:
> >  The point here is WHO does the reclaim. Sure we can do the reclaim in
> >  the guest but it is the host that has the memory pressure. To call into
> >  the guest is not a good idea, if you have an idle guest you generally
> >  increase the memory pressure because some of the guests pages might have
> >  been swapped which are needed if the guest has to do the reclaim. 
> 
> Cannot the guests employ text sharing?

Yes we can. We even had some patches for sharing the kernel text between
virtual machines. But the kernel text is only a small part of the memory
that gets accessed for a vmscan operation.

-- 
blue skies,
  Martin.

Martin Schwidefsky
Linux for zSeries Development & Services
IBM Deutschland Entwicklung GmbH

"Reality continues to ruin my life." - Calvin.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
