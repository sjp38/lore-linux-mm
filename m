Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 525786B0083
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 03:00:10 -0500 (EST)
Subject: Re: [MM] Make mm counters per cpu instead of atomic
From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
In-Reply-To: <alpine.DEB.2.00.0911230830300.26432@router.home>
References: <alpine.DEB.1.10.0911041409020.7409@V090114053VZO-1>
	 <1258440521.11321.32.camel@localhost> <1258443101.11321.33.camel@localhost>
	 <1258450465.11321.36.camel@localhost>
	 <alpine.DEB.1.10.0911171223460.20360@V090114053VZO-1>
	 <1258966270.29789.45.camel@localhost>
	 <alpine.DEB.2.00.0911230830300.26432@router.home>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Tue, 24 Nov 2009 16:02:33 +0800
Message-Id: <1259049753.29789.49.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Tejun Heo <tj@kernel.org>, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-11-23 at 08:31 -0600, Christoph Lameter wrote:
> On Mon, 23 Nov 2009, Zhang, Yanmin wrote:
> 
> > Another theoretic issue is below scenario:
> > Process A get the read lock on cpu 0 and is scheduled to cpu 2 to unlock. Then
> > it's scheduled back to cpu 0 to repeat the step. eventually, the reader counter
> > will overflow. Considering multiple thread cases, it might be faster to
> > overflow than what we imagine. When it overflows, processes will hang there.
> 
> True.... We need to find some alternative to per cpu data to scale mmap
> sem then.
I ran lots of benchmarks such like specjbb2005/hackbench/tbench/dbench/iozone
/sysbench_oltp(mysql)/aim7 against percpu tree(based on 2.6.32-rc7) on a 4*8*2 logical
cpu machine, and didn't find big result difference between with your patch and without
your patch.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
