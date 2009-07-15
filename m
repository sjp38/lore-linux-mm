Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 234B66B004F
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 00:48:58 -0400 (EDT)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e9.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n6F5D1VP015976
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 01:13:01 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n6F5PSW7257818
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 01:25:28 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n6F5PR5G032043
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 01:25:28 -0400
Date: Wed, 15 Jul 2009 10:55:25 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 0/5] Memory controller soft limit patches (v9)
Message-ID: <20090715052525.GG24034@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090710125950.5610.99139.sendpatchset@balbir-laptop> <20090715040811.GF24034@balbir.in.ibm.com> <20090715133324.e4683ef2.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090715133324.e4683ef2.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-07-15 13:33:24]:

> On Wed, 15 Jul 2009 09:38:11 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * Balbir Singh <balbir@linux.vnet.ibm.com> [2009-07-10 18:29:50]:
> > 
> > > 
> > > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > > 
> > > New Feature: Soft limits for memory resource controller.
> > > 
> > > Here is v9 of the new soft limit implementation. Soft limits is a new feature
> > > for the memory resource controller, something similar has existed in the
> > > group scheduler in the form of shares. The CPU controllers interpretation
> > > of shares is very different though. 
> > >
> > 
> > If there are no objections to these patches, could we pick them up for
> > testing in mmotm. 
> > 
> 
> If any, will be fixed up in mmotm. About behavior, I don't have more things
> than I've said. (dealying kswapd is not very good.)
> 
> But plz discuss with Vladislav Buzov about implementation details of [2..3/5].
> ==
> [PATCH 1/2] Resource usage threshold notification addition to res_counter (v3)
> 
> It seems there are multiple functionalities you can shere with them.
> 
>  - hierarchical threshold check
>  - callback or notify agaisnt threshold.
>  etc..
> 
> I'm very happy if all messy things around res_counter+hierarchy are sorted out
> before diving into melting pot. I hope both of you have nice interfaces and
> keep res_counter neat.
>

I do see scope for reuse, but I've not yet gotten to reviewing v3 of
the patches. I will, I could potentially get him to base his patches
on top of this. One of the interesting things that Paul pointed out
was of global state.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
