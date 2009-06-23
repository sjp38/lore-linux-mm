Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id CF16D6B0055
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 00:45:26 -0400 (EDT)
Subject: Re: [PATCH] Hugepages should be accounted as unevictable pages.
From: Alok Kataria <akataria@vmware.com>
Reply-To: akataria@vmware.com
In-Reply-To: <20090623093459.2204.A69D9226@jp.fujitsu.com>
References: <1245705941.26649.19.camel@alok-dev1>
	 <20090623093459.2204.A69D9226@jp.fujitsu.com>
Content-Type: text/plain
Date: Mon, 22 Jun 2009 21:46:51 -0700
Message-Id: <1245732411.18339.6.camel@alok-dev1>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Mon, 2009-06-22 at 20:25 -0700, KOSAKI Motohiro wrote:
> > Looking at the output of /proc/meminfo, a user might get confused in thinking
> > that there are zero unevictable pages, though, in reality their can be
> > hugepages which are inherently unevictable. 
> > 
> > Though hugepages are not handled by the unevictable lru framework, they are
> > infact unevictable in nature and global statistics counter should reflect that. 
> > 
> > For instance, I have allocated 20 huge pages on my system, meminfo shows this 
> > 
> > Unevictable:           0 kB
> > Mlocked:               0 kB
> > HugePages_Total:      20
> > HugePages_Free:       20
> > HugePages_Rsvd:        0
> > HugePages_Surp:        0
> > 
> > After the patch:
> > 
> > Unevictable:       81920 kB
> > Mlocked:               0 kB
> > HugePages_Total:      20
> > HugePages_Free:       20
> > HugePages_Rsvd:        0
> > HugePages_Surp:        0
> 
> At first, We should clarify the spec of unevictable.
> Currently, Unevictable field mean the number of pages in unevictable-lru
> and hugepage never insert any lru.
> 
> I think this patch will change this rule.

I agree, and that's why I added a comment to the documentation file to
that effect. If you think its not explicit or doesn't explain what its
supposed to we can add something more there.

IMO, the proc output should give the total number of unevictable pages
in the system and, since hugepages are also in fact unevictable so I
don't see a reason why they shouldn't be accounted accordingly.
What do you think ? 

Thanks,
Alok
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
