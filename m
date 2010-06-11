Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C20436B0071
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 01:13:18 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5B5DGxh018700
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 11 Jun 2010 14:13:16 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 78AF145DE52
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 14:13:16 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F8DE45DE54
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 14:13:16 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4BCEC1DB8012
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 14:13:16 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 013031DB8015
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 14:13:13 +0900 (JST)
Date: Fri, 11 Jun 2010 14:08:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC/T/D][PATCH 2/2] Linux/Guest cooperative unmapped page
 cache control
Message-Id: <20100611140842.e748d47d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100611140553.956f31ab.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100608155140.3749.74418.sendpatchset@L34Z31A.ibm.com>
	<20100608155153.3749.31669.sendpatchset@L34Z31A.ibm.com>
	<4C10B3AF.7020908@redhat.com>
	<20100610142512.GB5191@balbir.in.ibm.com>
	<1276214852.6437.1427.camel@nimitz>
	<20100611105441.ee657515.kamezawa.hiroyu@jp.fujitsu.com>
	<20100611044632.GD5191@balbir.in.ibm.com>
	<20100611140553.956f31ab.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, Dave Hansen <dave@linux.vnet.ibm.com>, Avi Kivity <avi@redhat.com>, kvm <kvm@vger.kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 11 Jun 2010 14:05:53 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> I can think of both way in kernel and in user approarh and they should be
> complement to each other.
> 
> An example of kernel-based approach is.
>  1. add a shrinker callback(A) for balloon-driver-for-guest as guest kswapd.
>  2. add a shrinker callback(B) for balloon-driver-for-host as host kswapd.
> (I guess current balloon driver is only for host. Please imagine.)
                                              ^^^^
                                              guest.
Sorry.
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
