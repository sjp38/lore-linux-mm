Date: Thu, 21 Aug 2008 03:26:34 -0700 (PDT)
Message-Id: <20080821.032634.14561915.davem@davemloft.net>
Subject: Re: [RFC][PATCH 2/2] quicklist shouldn't be proportional to # of
 CPUs
From: David Miller <davem@davemloft.net>
In-Reply-To: <20080821191330.22B2.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080821183648.22AF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080821.030932.75221247.davem@davemloft.net>
	<20080821191330.22B2.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Thu, 21 Aug 2008 19:13:55 +0900
Return-Path: <owner-linux-mm@kvack.org>
To: kosaki.motohiro@jp.fujitsu.com
Cc: peterz@infradead.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cl@linux-foundation.org, tokunaga.keiich@jp.fujitsu.com, travis@sgi.com
List-ID: <linux-mm.kvack.org>

> > From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > Date: Thu, 21 Aug 2008 19:04:28 +0900
> > 
> > > but I worry about it works on sparc64...
> > 
> > It should.
> 
> Could you please confirm it?

davem@sunset:~/src/GIT/net-2.6$ patch -p1 <diff
patching file mm/quicklist.c
davem@sunset:~/src/GIT/net-2.6$ make mm/quicklist.o
  CHK     include/linux/version.h
  CHK     include/linux/utsrelease.h
  CALL    scripts/checksyscalls.sh
  CC      mm/quicklist.o
davem@sunset:~/src/GIT/net-2.6$ 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
