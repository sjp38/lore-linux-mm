Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lBDI2UO8030288
	for <linux-mm@kvack.org>; Thu, 13 Dec 2007 13:02:30 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBDI2Ua1372106
	for <linux-mm@kvack.org>; Thu, 13 Dec 2007 13:02:30 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBDI2TqG005197
	for <linux-mm@kvack.org>; Thu, 13 Dec 2007 13:02:30 -0500
Date: Thu, 13 Dec 2007 10:01:48 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC][PATCH 3/3] Documetation: update hugetlb information
Message-ID: <20071213180148.GG17526@us.ibm.com>
References: <20071213074156.GA17526@us.ibm.com> <1197562629.21438.20.camel@localhost> <20071213164453.GC17526@us.ibm.com> <1197565364.21438.23.camel@localhost> <20071213180116.GF17526@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071213180116.GF17526@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: agl@us.ibm.com, wli@holomorphy.com, mel@csn.ul.ie, apw@shadowen.org, akpm@linux-foundation.org, lee.schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 13.12.2007 [10:01:16 -0800], Nishanth Aravamudan wrote:
> On 13.12.2007 [09:02:44 -0800], Dave Hansen wrote:
> > On Thu, 2007-12-13 at 08:44 -0800, Nishanth Aravamudan wrote:
> > > Err, yes, will need to updated that. I note that the old sysctl is not
> > > there...nor is nr_hugepages, for that matter. So maybe I'll just add a
> > > 3rd patch to fix the Documentation? I really just wanted to get the
> > > patches out there as soon as I got them tested... 
> > 
> > Yeah, that should be fine.  Adding nr_hugepages will probably get you
> > bonus points. :)
> 
> Documentation: updated hugetlb information

Clearly this is what the subject of the mail should have been too. Sorry
for the typo...

-Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
