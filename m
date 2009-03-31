Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C9B706B003D
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 19:57:47 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2VNwewr027777
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 1 Apr 2009 08:58:40 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id F374545DD7E
	for <linux-mm@kvack.org>; Wed,  1 Apr 2009 08:58:39 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id ADFCE45DD7D
	for <linux-mm@kvack.org>; Wed,  1 Apr 2009 08:58:39 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 61AC0E08002
	for <linux-mm@kvack.org>; Wed,  1 Apr 2009 08:58:39 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A4701DB803C
	for <linux-mm@kvack.org>; Wed,  1 Apr 2009 08:58:39 +0900 (JST)
Date: Wed, 1 Apr 2009 08:57:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] add ksm kernel shared memory driver.
Message-Id: <20090401085710.d2f0b267.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <49D20AE1.4060802@redhat.com>
References: <1238457560-7613-1-git-send-email-ieidus@redhat.com>
	<1238457560-7613-2-git-send-email-ieidus@redhat.com>
	<1238457560-7613-3-git-send-email-ieidus@redhat.com>
	<1238457560-7613-4-git-send-email-ieidus@redhat.com>
	<1238457560-7613-5-git-send-email-ieidus@redhat.com>
	<20090331111510.dbb712d2.kamezawa.hiroyu@jp.fujitsu.com>
	<49D20AE1.4060802@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, aarcange@redhat.com, chrisw@redhat.com, riel@redhat.com, jeremy@goop.org, mtosatti@redhat.com, hugh@veritas.com, corbet@lwn.net, yaniv@redhat.com, dmonakhov@openvz.org
List-ID: <linux-mm.kvack.org>

On Tue, 31 Mar 2009 15:21:53 +0300
Izik Eidus <ieidus@redhat.com> wrote:
> >   
> kpage is actually what going to be KsmPage -> the shared page...
> 
> Right now this pages are not swappable..., after ksm will be merged we 
> will make this pages swappable as well...
> 
sure.

> > If so, please
> >  - show the amount of kpage
> >  
> >  - allow users to set limit for usage of kpages. or preserve kpages at boot or
> >    by user's command.
> >   
> 
> kpage actually save memory..., and limiting the number of them, would 
> make you limit the number of shared pages...
> 

Ah, I'm working for memory control cgroup. And *KSM* will be out of control.
It's ok to make the default limit value as INFINITY. but please add knobs.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
