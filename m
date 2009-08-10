Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 3DDC36B005D
	for <linux-mm@kvack.org>; Sun,  9 Aug 2009 20:45:35 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7A0jb02021472
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 10 Aug 2009 09:45:37 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E18645DE4C
	for <linux-mm@kvack.org>; Mon, 10 Aug 2009 09:45:36 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4DB7045DE52
	for <linux-mm@kvack.org>; Mon, 10 Aug 2009 09:45:36 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id BA84BE1800A
	for <linux-mm@kvack.org>; Mon, 10 Aug 2009 09:45:35 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 646D21DB803F
	for <linux-mm@kvack.org>; Mon, 10 Aug 2009 09:45:35 +0900 (JST)
Date: Mon, 10 Aug 2009 09:43:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Help Resource Counters Scale Better (v3)
Message-Id: <20090810094344.77a8ef55.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090810093229.10db7185.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090807221238.GJ9686@balbir.in.ibm.com>
	<39eafe409b85053081e9c6826005bb06.squirrel@webmail-b.css.fujitsu.com>
	<20090808060531.GL9686@balbir.in.ibm.com>
	<99f2a13990d68c34c76c33581949aefd.squirrel@webmail-b.css.fujitsu.com>
	<20090809121530.GA5833@balbir.in.ibm.com>
	<20090810093229.10db7185.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, andi.kleen@intel.com, Prarit Bhargava <prarit@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>, Pavel Emelianov <xemul@openvz.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 10 Aug 2009 09:32:29 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> 1. you use res_counter_read_positive() in force_empty. It seems force_empty can
>    go into infinite loop. plz check. (especially when some pages are freed or swapped-in
>    in other cpu while force_empry runs.)
> 
> 2. In near future, we'll see 256 or 1024 cpus on a system, anyway.
>    Assume 1024cpu system, 64k*1024=64M is a tolerance.
>    Can't we calculate max-tolerane as following ?
>   
>    tolerance = min(64k * num_online_cpus(), limit_in_bytes/100);
>    tolerance /= num_online_cpus();
>    per_cpu_tolerance = min(16k, tolelance);
> 
>    I think automatic runtine adjusting of tolerance will be finally necessary,
>    but above will not be very bad because we can guarantee 1% tolerance.
> 

Sorry, one more.

3. As I requested when you pushed softlimit changes to mmotom, plz consider
   to implement a way to check-and-notify gadget to res_counter.
   See: http://marc.info/?l=linux-mm&m=124753058921677&w=2

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
