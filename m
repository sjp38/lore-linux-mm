Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6C2966B0012
	for <linux-mm@kvack.org>; Sun, 15 May 2011 15:53:43 -0400 (EDT)
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id p4FJrfX0006273
	for <linux-mm@kvack.org>; Sun, 15 May 2011 12:53:41 -0700
Received: from qyk10 (qyk10.prod.google.com [10.241.83.138])
	by hpaq7.eem.corp.google.com with ESMTP id p4FJrdv0019753
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 15 May 2011 12:53:40 -0700
Received: by qyk10 with SMTP id 10so2374916qyk.4
        for <linux-mm@kvack.org>; Sun, 15 May 2011 12:53:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110513185152.56c41483.kamezawa.hiroyu@jp.fujitsu.com>
References: <1305276473-14780-1-git-send-email-gthelen@google.com>
 <1305276473-14780-10-git-send-email-gthelen@google.com> <20110513185152.56c41483.kamezawa.hiroyu@jp.fujitsu.com>
From: Greg Thelen <gthelen@google.com>
Date: Sun, 15 May 2011 12:53:19 -0700
Message-ID: <BANLkTi=0_H_6a0yrpbnnqJJ-_aWv8suqfQ@mail.gmail.com>
Subject: Re: [RFC][PATCH v7 09/14] cgroup: move CSS_ID_MAX to cgroup.h
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Vivek Goyal <vgoyal@redhat.com>, Dave Chinner <david@fromorbit.com>

On Fri, May 13, 2011 at 2:51 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 13 May 2011 01:47:48 -0700
> Greg Thelen <gthelen@google.com> wrote:
>
>> This allows users of css_id() to know the largest possible css_id value.
>> This knowledge can be used to build per-cgroup bitmaps.
>>
>> Signed-off-by: Greg Thelen <gthelen@google.com>
>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> Hmm, I think this can be merged to following bitmap patch.

Ok.  I will merge this in following patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
