Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id E852A6B0044
	for <linux-mm@kvack.org>; Sun,  6 May 2012 23:20:38 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id D628A3EE0BB
	for <linux-mm@kvack.org>; Mon,  7 May 2012 12:20:36 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id BDA3E45DE56
	for <linux-mm@kvack.org>; Mon,  7 May 2012 12:20:36 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 997C645DE5D
	for <linux-mm@kvack.org>; Mon,  7 May 2012 12:20:36 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 845EDE08001
	for <linux-mm@kvack.org>; Mon,  7 May 2012 12:20:36 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D418E08006
	for <linux-mm@kvack.org>; Mon,  7 May 2012 12:20:36 +0900 (JST)
Message-ID: <4FA73EDE.1010807@jp.fujitsu.com>
Date: Mon, 07 May 2012 12:17:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: slub memory hotplug: Allocate kmem_cache_node structure on new
 node
References: <alpine.DEB.2.00.1204271020530.29198@router.home> <CAHGf_=rcQXTpOW_-x8fi-RnS5MihkFY8D3pMLDffDYUWom8Q9Q@mail.gmail.com>
In-Reply-To: <CAHGf_=rcQXTpOW_-x8fi-RnS5MihkFY8D3pMLDffDYUWom8Q9Q@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

(2012/04/28 22:14), KOSAKI Motohiro wrote:

> On Fri, Apr 27, 2012 at 11:29 AM, Christoph Lameter <cl@linux.com> wrote:
>> Could you test this patch and see if it does the correct thing on a memory
>> hotplug system?
> 
> Hmm..
> 
> Kamezawa-san, I can't access hotplug machine a while (maybe about 2 weeks).
> Do you have any chance to do this?
> 

Sorry, I can't for a while. I CC'ed a dynamic-partitioing guy.

At quick glance, the patch seems okay to me.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
