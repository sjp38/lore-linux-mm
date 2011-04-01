Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D95278D0040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 22:36:55 -0400 (EDT)
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id p312arhr005773
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 19:36:53 -0700
Received: from qwj9 (qwj9.prod.google.com [10.241.195.73])
	by kpbe12.cbf.corp.google.com with ESMTP id p312aqE3023751
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 19:36:52 -0700
Received: by qwj9 with SMTP id 9so2596593qwj.21
        for <linux-mm@kvack.org>; Thu, 31 Mar 2011 19:36:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTi=D8pfyxf3Vr33YZvuQm9fQv+bthyiLLeRjaJt6@mail.gmail.com>
References: <20110331110113.a01f7b8b.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTi=D8pfyxf3Vr33YZvuQm9fQv+bthyiLLeRjaJt6@mail.gmail.com>
Date: Thu, 31 Mar 2011 19:36:51 -0700
Message-ID: <BANLkTimQw1LQ6+gDFbex-C-5=gVqJf7ZPg@mail.gmail.com>
Subject: Re: [LSF][MM] rough agenda for memcg.
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, lsf@lists.linux-foundation.org, linux-mm@kvack.org, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On Thu, Mar 31, 2011 at 2:15 AM, Zhu Yanhai <zhu.yanhai@gmail.com> wrote:
> Hi Kame,
>
> 2011/3/31 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>:
>> =A0c) Should we provide a auto memory cgroup for file caches ?
>> =A0 =A0 (Then we can implement a file-cache-limit.)
>> =A0c) AFAIK, some other OSs have this kind of feature, a box for file-ca=
che.
>> =A0 =A0 Because file-cache is a shared object between all cgroups, it's =
difficult
>> =A0 =A0 to handle. It may be better to have a auto cgroup for file cache=
s and add knobs
>> =A0 =A0 for memcg.
>
> I have been thinking about this idea. It seems the root cause of
> current difficult is
> the whole cgroup infrastructure is based on process groups, so its counte=
rs
> naturally center on process. However, this is not nature for counters
> of file caches,
> which center on inodes/devs actually. This brought many confusing
> problems - e.g.
> who should be charged for a (dirty)file page? =A0I think the answer is
> no process but
> the filesystem/block device it sits on.

This has been an open issue for Google as well. Greg Thelen gave this
some though last year and had a proposal around the idea of forcing
files within certain directories to be accounted to a given cgroup.
We're not actively implementing this right now, but if there is
outside interest this might be worth discussing (might just be as an
informal conversation rather than a session though).

--=20
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
