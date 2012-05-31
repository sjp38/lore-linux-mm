Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id 070D26B005C
	for <linux-mm@kvack.org>; Thu, 31 May 2012 02:56:15 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so1256060pbb.14
        for <linux-mm@kvack.org>; Wed, 30 May 2012 23:56:15 -0700 (PDT)
Date: Wed, 30 May 2012 23:56:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] meminfo: show /proc/meminfo base on container's memcg
In-Reply-To: <4FC711A5.4090003@gmail.com>
Message-ID: <alpine.DEB.2.00.1205302351510.25774@chino.kir.corp.google.com>
References: <1338260214-21919-1-git-send-email-gaofeng@cn.fujitsu.com> <alpine.DEB.2.00.1205301433490.9716@chino.kir.corp.google.com> <4FC6B68C.2070703@jp.fujitsu.com> <CAHGf_=pFbsy4FO_UNu6O1-KyTd6O=pkmR8=3EGuZB5Reu3Vb9w@mail.gmail.com> <4FC6BC3E.5010807@jp.fujitsu.com>
 <alpine.DEB.2.00.1205301737530.25774@chino.kir.corp.google.com> <4FC6C111.2060108@jp.fujitsu.com> <alpine.DEB.2.00.1205301831270.25774@chino.kir.corp.google.com> <4FC6D881.4090706@jp.fujitsu.com> <alpine.DEB.2.00.1205302156090.25774@chino.kir.corp.google.com>
 <4FC70355.70805@jp.fujitsu.com> <alpine.DEB.2.00.1205302314190.25774@chino.kir.corp.google.com> <4FC70E5E.1010003@gmail.com> <alpine.DEB.2.00.1205302325500.25774@chino.kir.corp.google.com> <4FC711A5.4090003@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Gao feng <gaofeng@cn.fujitsu.com>, hannes@cmpxchg.org, mhocko@suse.cz, bsingharora@gmail.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, containers@lists.linux-foundation.org

On Thu, 31 May 2012, KOSAKI Motohiro wrote:

> > This is tangent to the discussion, we need to revisit why an application
> > other than a daemon managing a set of memcgs would ever need to know the
> > information in /proc/meminfo.  No use-case was ever presented in the
> > changelog and its not clear how this is at all relevant.  So before
> > changing the kernel, please describe how this actually matters in a real-
> > world scenario.
> 
> Huh? Don't you know a meanings of a namespace ISOLATION? isolation mean,
> isolated container shouldn't be able to access global information. If you
> want to lean container/namespace concept, tasting openvz or solaris container
> is a good start.
> 

As I said, LXC and namespace isolation is a tangent to the discussion of 
faking the /proc/meminfo for the memcg context of a thread.

> But anyway, I dislike current implementaion. So, I NAK this patch too.
> 

I'm glad you reached that conclusion, but I think you did so for a much 
different (although unspecified) reason.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
