Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 577276B009E
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 11:48:38 -0400 (EDT)
Received: from fgwmail7.fujitsu.co.jp (fgwmail7.fujitsu.co.jp [192.51.44.37])
	by fgwmail9.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7L0bUma022693
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 21 Aug 2009 09:37:30 +0900
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7L0atdn011756
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 21 Aug 2009 09:36:55 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 54B9145DE51
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 09:36:55 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 327E245DD77
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 09:36:55 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 165B71DB8038
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 09:36:55 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C58301DB8040
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 09:36:51 +0900 (JST)
Date: Fri, 21 Aug 2009 09:34:52 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Patch 8/8] kexec: allow to shrink reserved memory
Message-Id: <20090821093452.ead96b2d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4A8D144C.5050005@redhat.com>
References: <20090812081731.5757.25254.sendpatchset@localhost.localdomain>
	<20090812081906.5757.39417.sendpatchset@localhost.localdomain>
	<m1bpmk8l1g.fsf@fess.ebiederm.org>
	<4A83893D.50707@redhat.com>
	<m1eirg5j9i.fsf@fess.ebiederm.org>
	<4A83CD84.8040609@redhat.com>
	<m1tz0avy4h.fsf@fess.ebiederm.org>
	<4A8927DD.6060209@redhat.com>
	<20090818092939.2efbe158.kamezawa.hiroyu@jp.fujitsu.com>
	<4A8A4ABB.70003@redhat.com>
	<20090818172552.779d0768.kamezawa.hiroyu@jp.fujitsu.com>
	<4A8A83F4.6010408@redhat.com>
	<20090819085703.ccf9992a.kamezawa.hiroyu@jp.fujitsu.com>
	<4A8B6649.3080103@redhat.com>
	<20090819171346.aadfeb2c.kamezawa.hiroyu@jp.fujitsu.com>
	<4A8D144C.5050005@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Amerigo Wang <amwang@redhat.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-mm@kvack.org, Neil Horman <nhorman@redhat.com>, Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, bernhard.walle@gmx.de, Fenghua Yu <fenghua.yu@intel.com>, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>
List-ID: <linux-mm.kvack.org>

On Thu, 20 Aug 2009 17:15:56 +0800
Amerigo Wang <amwang@redhat.com> wrote:
    
> > The, problem is whether memmap is there or not. That's all.
> > plz see init sequence and check there are memmap.
> > If memory-for-crash is obtained via bootmem,
> > Don't you try to free memory hole ?
> >   
> 
> Hi,
> 
> It looks like that mem_map has 'struct page' for the reserved memory, I 
> checked my "early_node_map[] active PFN ranges" output, the reserved 
> memory area for crash kernel is right in one range. Am I missing 
> something here?
> 
> I don't know why that oops comes out, maybe because of no PTE for thoese 
> pages?
> 
Hmm ? Could you show me the code you use ?

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
