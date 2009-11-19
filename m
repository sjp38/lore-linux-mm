Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 5E8066B004D
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 19:45:44 -0500 (EST)
Subject: Re: [MM] Make mm counters per cpu instead of atomic
From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
In-Reply-To: <alpine.DEB.1.10.0911171223460.20360@V090114053VZO-1>
References: <alpine.DEB.1.10.0911041409020.7409@V090114053VZO-1>
	 <1258440521.11321.32.camel@localhost> <1258443101.11321.33.camel@localhost>
	 <1258450465.11321.36.camel@localhost>
	 <alpine.DEB.1.10.0911171223460.20360@V090114053VZO-1>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Thu, 19 Nov 2009 08:48:07 +0800
Message-Id: <1258591687.11321.42.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Tejun Heo <tj@kernel.org>, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2009-11-17 at 12:25 -0500, Christoph Lameter wrote:
> On Tue, 17 Nov 2009, Zhang, Yanmin wrote:
> 
> > The right change above should be:
> >  struct mm_counter *m = per_cpu_ptr(mm->rss, cpu);
> 
> Right.
> 
> > With the change, command 'make oldconfig' and a boot command still
> > hangs.
> 
> Not sure if its worth spending more time on this but if you want I will
> consolidate the fixes so far and put out another patchset.
> 
> Where does it hang during boot?
> 
1) A init boot script calss pidof and pidof hands in
access_process_vm => (mutex_lock <=> mutex_unlock), so actually in
mm_reader_lock.
2) 'make oldconfig' hangs in sys_map => msleep, actually in mm_writer_lock.

I will check it today.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
