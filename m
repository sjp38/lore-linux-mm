Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 5CB0E6B005C
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 20:05:49 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id AE7E13EE0C0
	for <linux-mm@kvack.org>; Fri,  9 Dec 2011 10:05:47 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 982AF45DEB5
	for <linux-mm@kvack.org>; Fri,  9 Dec 2011 10:05:47 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7DF4445DEAD
	for <linux-mm@kvack.org>; Fri,  9 Dec 2011 10:05:47 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F8EE1DB8044
	for <linux-mm@kvack.org>; Fri,  9 Dec 2011 10:05:47 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 236BE1DB803C
	for <linux-mm@kvack.org>; Fri,  9 Dec 2011 10:05:47 +0900 (JST)
Date: Fri, 9 Dec 2011 10:04:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v8 0/9] per-cgroup tcp memory pressure controls
Message-Id: <20111209100420.feaef96a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4EDF48A9.6090306@parallels.com>
References: <1323120903-2831-1-git-send-email-glommer@parallels.com>
	<4EDF48A9.6090306@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, lizf@cn.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org, eric.dumazet@gmail.com, cgroups@vger.kernel.org, hannes@cmpxchg.org, mhocko@suse.cz

On Wed, 7 Dec 2011 09:06:17 -0200
Glauber Costa <glommer@parallels.com> wrote:

> On 12/05/2011 07:34 PM, Glauber Costa wrote:
> > Hi,
> >
> > This is my new attempt to fix all the concerns that were raised during
> > the last iteration.
> >
> > I should highlight:
> > 1) proc information is kept intact. (although I kept the wrapper functions)
> >     it will be submitted as a follow up patch so it can get the attention it
> >     deserves
> > 2) sockets now hold a reference to memcg. sockets can be alive even after the
> >     task is gone, so we don't bother with between cgroups movements.
> >     To be able to release resources more easily in this cenario, the parent
> >     pointer in struct cg_proto was replaced by a memcg object. We then iterate
> >     through its pointer (which is cleaner anyway)
> >
> > The rest should be mostly the same except for small fixes and style changes.
> >
> 
> Kame,
> 
> Does this one address your previous concerns?
> 
Your highlight seems good. I'll look into details.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
