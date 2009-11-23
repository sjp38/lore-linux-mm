Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id AD0726B0044
	for <linux-mm@kvack.org>; Mon, 23 Nov 2009 09:32:53 -0500 (EST)
Date: Mon, 23 Nov 2009 08:31:40 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [MM] Make mm counters per cpu instead of atomic
In-Reply-To: <1258966270.29789.45.camel@localhost>
Message-ID: <alpine.DEB.2.00.0911230830300.26432@router.home>
References: <alpine.DEB.1.10.0911041409020.7409@V090114053VZO-1>  <1258440521.11321.32.camel@localhost> <1258443101.11321.33.camel@localhost>  <1258450465.11321.36.camel@localhost>  <alpine.DEB.1.10.0911171223460.20360@V090114053VZO-1>
 <1258966270.29789.45.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Tejun Heo <tj@kernel.org>, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Nov 2009, Zhang, Yanmin wrote:

> Another theoretic issue is below scenario:
> Process A get the read lock on cpu 0 and is scheduled to cpu 2 to unlock. Then
> it's scheduled back to cpu 0 to repeat the step. eventually, the reader counter
> will overflow. Considering multiple thread cases, it might be faster to
> overflow than what we imagine. When it overflows, processes will hang there.

True.... We need to find some alternative to per cpu data to scale mmap
sem then.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
