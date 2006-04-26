Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.6/8.13.6) with ESMTP id k3Q7de9s069682
	for <linux-mm@kvack.org>; Wed, 26 Apr 2006 07:39:40 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k3Q7ejMs107842
	for <linux-mm@kvack.org>; Wed, 26 Apr 2006 09:40:45 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id k3Q7ddtW014430
	for <linux-mm@kvack.org>; Wed, 26 Apr 2006 09:39:39 +0200
Subject: Re: Page host virtual assist patches.
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
In-Reply-To: <444EC953.6060309@yahoo.com.au>
References: <20060424123412.GA15817@skybase>
	 <20060424180138.52e54e5c.akpm@osdl.org>  <444DCD87.2030307@yahoo.com.au>
	 <1145953914.5282.21.camel@localhost>  <444DF447.4020306@yahoo.com.au>
	 <1145964531.5282.59.camel@localhost>  <444E1253.9090302@yahoo.com.au>
	 <1145974521.5282.89.camel@localhost>  <444EC953.6060309@yahoo.com.au>
Content-Type: text/plain
Date: Wed, 26 Apr 2006 09:39:44 +0200
Message-Id: <1146037185.5192.3.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, frankeh@watson.ibm.com, rhim@cc.gatech.edu
List-ID: <linux-mm.kvack.org>

On Wed, 2006-04-26 at 11:13 +1000, Nick Piggin wrote:
> OK, we'll agree to disagree for now :)
> 
> I did start looking at the code but as you can see I only reviewed
> patch 1 before getting sidetracked. I'll try to find some more time
> to look at in the next few days.

Thanks Nick, that would be greatly appreciated. The code is hard to
understand, it's memory races squared. Races of the hypervisor actions
against races in the Linux mm. Lovely. It took use quite a while to get
that beast working, on z/VM, Linux and the millicode. 

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
