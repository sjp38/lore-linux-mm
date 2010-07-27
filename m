Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 27EAF6007F9
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 07:17:07 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6RBH4cU027129
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 27 Jul 2010 20:17:04 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 057CE45DE52
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 20:17:04 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D386045DE4D
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 20:17:03 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B724CE08002
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 20:17:03 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5D3E71DB804D
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 20:17:03 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] Add trace points to mmap, munmap, and brk
In-Reply-To: <20100727110904.GA6519@mgebm.net>
References: <20100721223359.8710.A69D9226@jp.fujitsu.com> <20100727110904.GA6519@mgebm.net>
Message-Id: <20100727201644.2F46.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 27 Jul 2010 20:17:02 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <emunson@mgebm.net>
Cc: kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, mingo@redhat.com, hugh.dickins@tiscali.co.uk, riel@redhat.com, peterz@infradead.org, anton@samba.org, hch@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Wed, 21 Jul 2010, KOSAKI Motohiro wrote:
> 
> > > This patch adds trace points to mmap, munmap, and brk that will report
> > > relevant addresses and sizes before each function exits successfully.
> > > 
> > > Signed-off-by: Eric B Munson <emunson@mgebm.net>
> > 
> > I don't think this is good idea. if you need syscall result, you should 
> > use syscall tracer. IOW, This tracepoint bring zero information.
> > 
> > Please see perf_event_mmap() usage. Our kernel manage adress space by
> > vm_area_struct. we need to trace it if we need to know what kernel does.
> > 
> > Thanks.
> 
> The syscall tracer does not give you the address and size of the mmaped areas
> so this does provide information above simply tracing the enter/exit points
> for each call.

Why don't you fix this?



> perf_event_mmap does provide the information for mmap calls.  Originally I sent
> a patch to add a trace point to munmap and Peter Z asked for corresponding points
> in the mmap family.  If the consensus is that the trace point in munmap is the
> only one that should be added I can resend that patch.
> 
> -- 
> Eric B Munson
> IBM Linux Technology Center
> ebmunson@us.ibm.com
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
