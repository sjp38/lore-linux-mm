Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 8AF2E6B004A
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 21:49:13 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 9DC153EE081
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 11:49:11 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 836CF45DE50
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 11:49:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 68D7845DD74
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 11:49:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B0421DB803E
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 11:49:11 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1294C1DB803A
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 11:49:11 +0900 (JST)
Date: Fri, 24 Feb 2012 11:47:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: Enable MAP_UNINITIALIZED for archs with mmu
Message-Id: <20120224114748.720ee79a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4F468888.9090702@fb.com>
References: <1326912662-18805-1-git-send-email-asharma@fb.com>
	<CAKTCnzn-reG4bLmyWNYPELYs-9M3ZShEYeOix_OcnPow-w8PNg@mail.gmail.com>
	<4F468888.9090702@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun Sharma <asharma@fb.com>
Cc: Balbir Singh <bsingharora@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org

On Thu, 23 Feb 2012 10:42:16 -0800
Arun Sharma <asharma@fb.com> wrote:

> Hi Balbir,
> 
> Thanks for reviewing. Would you change your position if I limit the 
> scope of the patch to a cgroup with a single address space?
> 
> The moment the cgroup sees more than one address space (either due to 
> tasks getting created or being added), this optimization would be turned 
> off.
> 
> More details below:
> 
> On 2/22/12 11:45 PM, Balbir Singh wrote:
> >
> > So the assumption is that only apps that have access to each others
> > VMA's will run in this cgroup?
> >
> 
> In a distributed computing environment, a user submits a job to the 
> cluster job scheduler. The job might involve multiple related 
> executables and might involve multiple address spaces. But they're 
> performing one logical task, have a single resource limit enforced by a 
> cgroup.
> 
> They don't have access to each other's VMAs, but if "accidentally" one 
> of them comes across an uninitialized page with data from another task, 
> it's not a violation of the security model.
> 
How do you handle shared resouce, file-cache ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
