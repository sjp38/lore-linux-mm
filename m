Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 926AD900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 02:20:44 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id D2E663EE0AE
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 15:20:39 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id BB3E445DE55
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 15:20:39 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A1FA245DE58
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 15:20:39 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 945DC1DB8043
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 15:20:39 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4EFCA1DB803F
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 15:20:39 +0900 (JST)
Date: Thu, 23 Jun 2011 15:13:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: "make -j" with memory.(memsw.)limit_in_bytes smaller than
 required -> livelock,  even for unlimited processes
Message-Id: <20110623151340.61d7d7df.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4E01BB86.5010708@5t9.de>
References: <4E00AFE6.20302@5t9.de>
	<20110622091018.16c14c78.kamezawa.hiroyu@jp.fujitsu.com>
	<4E01BB86.5010708@5t9.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lutz Vieweg <lvml@5t9.de>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org

On Wed, 22 Jun 2011 11:53:10 +0200
Lutz Vieweg <lvml@5t9.de> wrote:

> On 06/22/2011 02:10 AM, KAMEZAWA Hiroyuki wrote:

> > Then, waiting for some page bit...I/O of libc mapped pages ?
> >
> > Hmm. it seems buggy behavior. Okay, I'll dig this.
> 
> Thanks a lot for investigating!
> 

This patch works for me. please see the thread
https://lkml.org/lkml/2011/6/22/163, too.
==
