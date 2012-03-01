Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id D63116B002C
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 21:13:27 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id B60953EE0C3
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 11:13:25 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C5A345DEB6
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 11:13:25 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8622045DEB5
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 11:13:25 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7AF471DB803C
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 11:13:25 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3435F1DB8042
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 11:13:25 +0900 (JST)
Date: Thu, 1 Mar 2012 11:11:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/7] small cleanup for memcontrol.c
Message-Id: <20120301111147.8145b9d2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4F4E60BB.9030007@parallels.com>
References: <1329824079-14449-1-git-send-email-glommer@parallels.com>
	<1329824079-14449-2-git-send-email-glommer@parallels.com>
	<20120222094619.caffc432.kamezawa.hiroyu@jp.fujitsu.com>
	<4F44F54A.8010902@parallels.com>
	<4F4E60BB.9030007@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, devel@openvz.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Greg Thelen <gthelen@google.com>, Johannes Weiner <jweiner@redhat.com>, Michal Hocko <mhocko@suse.cz>, Paul Turner <pjt@google.com>, Frederic Weisbecker <fweisbec@gmail.com>

On Wed, 29 Feb 2012 14:30:35 -0300
Glauber Costa <glommer@parallels.com> wrote:

> On 02/22/2012 12:01 PM, Glauber Costa wrote:
> > On 02/22/2012 04:46 AM, KAMEZAWA Hiroyuki wrote:
> >> On Tue, 21 Feb 2012 15:34:33 +0400
> >> Glauber Costa<glommer@parallels.com> wrote:
> >>
> >>> Move some hardcoded definitions to an enum type.
> >>>
> >>> Signed-off-by: Glauber Costa<glommer@parallels.com>
> >>> CC: Kirill A. Shutemov<kirill@shutemov.name>
> >>> CC: Greg Thelen<gthelen@google.com>
> >>> CC: Johannes Weiner<jweiner@redhat.com>
> >>> CC: Michal Hocko<mhocko@suse.cz>
> >>> CC: Hiroyouki Kamezawa<kamezawa.hiroyu@jp.fujitsu.com>
> >>> CC: Paul Turner<pjt@google.com>
> >>> CC: Frederic Weisbecker<fweisbec@gmail.com>
> >>
> >> seems ok to me.
> >>
> >> Acked-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> >
> > BTW, this series is likely to go through many rounds of discussion.
> > This patch can be probably picked separately, if you want to.
> >
> >> a nitpick..
> >>
> >>> ---
> >>> mm/memcontrol.c | 10 +++++++---
> >>> 1 files changed, 7 insertions(+), 3 deletions(-)
> >>>
> >>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> >>> index 6728a7a..b15a693 100644
> >>> --- a/mm/memcontrol.c
> >>> +++ b/mm/memcontrol.c
> >>> @@ -351,9 +351,13 @@ enum charge_type {
> >>> };
> >>>
> >>> /* for encoding cft->private value on file */
> >>> -#define _MEM (0)
> >>> -#define _MEMSWAP (1)
> >>> -#define _OOM_TYPE (2)
> >>> +
> >>> +enum mem_type {
> >>> + _MEM = 0,
> >>
> >> =0 is required ?
> > I believe not, but I always liked to use it to be 100 % explicit.
> > Personal taste... Can change it, if this is a big deal.
> 
> Kame, would you like me to send this cleanup without the = 0 ?
> 

Not necessary.  Sorry for delayed response.
Lots of memcg patches are flying..

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
