Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9H0V8C6000561
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 17 Oct 2008 09:31:08 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F31F24004A
	for <linux-mm@kvack.org>; Fri, 17 Oct 2008 09:31:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 72E1A2DC07B
	for <linux-mm@kvack.org>; Fri, 17 Oct 2008 09:31:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B58A1DB8037
	for <linux-mm@kvack.org>; Fri, 17 Oct 2008 09:31:08 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0FF281DB803F
	for <linux-mm@kvack.org>; Fri, 17 Oct 2008 09:31:08 +0900 (JST)
Date: Fri, 17 Oct 2008 09:30:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: mmotm 2008-10-16-00-52 uploaded (cgroup + mm)
Message-Id: <20081017093046.80ae7d14.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0810161400230.14604@shark.he.net>
References: <200810160758.m9G7wZmt018529@imap1.linux-foundation.org>
	<Pine.LNX.4.64.0810161400230.14604@shark.he.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Randy.Dunlap" <rdunlap@xenotime.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 16 Oct 2008 14:01:48 -0700 (PDT)
"Randy.Dunlap" <rdunlap@xenotime.net> wrote:

> On Thu, 16 Oct 2008, akpm@linux-foundation.org wrote:
> 
> > The mm-of-the-moment snapshot 2008-10-16-00-52 has been uploaded to
> > 
> >    http://userweb.kernel.org/~akpm/mmotm/
> > 
> > It contains the following patches against 2.6.27:
> 
> 
> build-r9168.out:(.text+0x261e6): undefined reference to `lookup_page_cgroup'
> build-r9168.out:memcontrol.c:(.text+0x2629f): undefined reference to `lookup_page_cgroup'
> build-r9168.out:memcontrol.c:(.text+0x2671a): undefined reference to `lookup_page_cgroup'
> build-r9168.out:(.text+0x268f9): undefined reference to `lookup_page_cgroup'
> build-r9168.out:memcontrol.c:(.text+0x26e52): undefined reference to `page_cgroup_init'
> build-r9168.out:(.text+0x26f44): undefined reference to `lookup_page_cgroup'
> build-r9168.out:(.init.text+0xe42): undefined reference to `pgdat_page_cgroup_init'
> 
> 
> .config is at http://oss.oracle.com/~rdunlap/kerneltest/configs/config-r9168
> 
Ouch...

Hmm....it seems

memcg-allocate-all-page_cgroup-at-boot.patch doesn't includes changes to Makefile...

Thank you for report. I'll send a fix soon.

Regards,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
