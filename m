Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C01B16B003D
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 13:44:08 -0400 (EDT)
Subject: Re: PROBLEM: kernel BUG at mm/slab.c:3002!
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <49B6A374.6040805@hp.com>
References: <49B68450.9000505@hp.com> <1236705532.3205.14.camel@calx>
	 <49B6A374.6040805@hp.com>
Content-Type: text/plain
Date: Tue, 10 Mar 2009 12:43:50 -0500
Message-Id: <1236707030.3205.21.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Alan D. Brunelle" <Alan.Brunelle@hp.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, cl@linux-foundation.org, penberg@cs.helsinki.fi, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2009-03-10 at 13:29 -0400, Alan D. Brunelle wrote:
> Matt Mackall wrote:
> > On Tue, 2009-03-10 at 11:16 -0400, Alan D. Brunelle wrote:
> >> Running blktrace & I/O loads cause a kernel BUG at mm/slab.c:3002!.
> > 
> > Pid: 11346, comm: blktrace Tainted: G    B      2.6.29-rc7 #3 ProLiant
> > DL585 G5   
> > 
> > That 'B' there indicates you've hit 'bad page' before this. That bug
> > seems to be strongly correlated with some form of hardware trouble.
> > Unfortunately, that makes everything after that point a little suspect.
> 
> 
> /If/ it were a hardware issue, that might explain the subsequent issue
> when I switched to SLUB instead...

Well it was almost certainly not a bug in SLAB itself (and your SLUB
test is obviously quite conclusive there). We'd have lots of reports.
It's probably too early to conclude it's hardware though.

> How does one look for "bad page reports"?

It'll look something like this (pasted from Google):

>>     kernel: Bad page state at free_hot_cold_page (in process 'beam',
>> page c1a95320)
>>     kernel: flags:0x40020118 mapping:f401adc0 mapped:0 count:0
>> private:0x00000000

-- 
http://selenic.com : development and support for Mercurial and Linux


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
