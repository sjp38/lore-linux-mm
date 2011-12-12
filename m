Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 9A07A6B008A
	for <linux-mm@kvack.org>; Sun, 11 Dec 2011 19:36:04 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 895A63EE0C3
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 09:36:02 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6EE3E45DEEE
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 09:36:02 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 55CAB45DEEC
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 09:36:02 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 474891DB803F
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 09:36:02 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id EC67C1DB803B
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 09:36:01 +0900 (JST)
Date: Mon, 12 Dec 2011 09:34:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v8 1/9] Basic kernel memory functionality for the Memory
 Controller
Message-Id: <20111212093448.91c96f77.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4EE21D23.4000309@parallels.com>
References: <1323120903-2831-1-git-send-email-glommer@parallels.com>
	<1323120903-2831-2-git-send-email-glommer@parallels.com>
	<20111209102113.cdb85da8.kamezawa.hiroyu@jp.fujitsu.com>
	<4EE21D23.4000309@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, lizf@cn.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org, eric.dumazet@gmail.com, cgroups@vger.kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, Paul Menage <paul@paulmenage.org>

On Fri, 9 Dec 2011 12:37:23 -0200
Glauber Costa <glommer@parallels.com> wrote:

> On 12/08/2011 11:21 PM, KAMEZAWA Hiroyuki wrote:
> > Hm, why you check val != parent->kmem_independent_accounting ?
> >
> > 	if (parent&&  parent->use_hierarchy)
> > 		return -EINVAL;
> > ?
> >
> > BTW, you didn't check this cgroup has children or not.
> > I think
> >
> > 	if (this_cgroup->use_hierarchy&&
> >               !list_empty(this_cgroup->childlen))
> > 		return -EINVAL;
> 
> How about this?
> 
>          val = !!val;
> 
>          /*
>           * This follows the same hierarchy restrictions than
>           * mem_cgroup_hierarchy_write()
>           */
>          if (!parent || !parent->use_hierarchy) {
>                  if (list_empty(&cgroup->children))
>                          memcg->kmem_independent_accounting = val;
>                  else
>                          return -EBUSY;
>          }
>          else
>                  return -EINVAL;
> 
>          return 0;
> 
seems good to me.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
