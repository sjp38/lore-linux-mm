Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 3F7416B002C
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 02:32:05 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 83F653EE0C3
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 16:32:03 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 36DF645DE5A
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 16:32:03 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id ED35645DE56
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 16:32:02 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DEC351DB802F
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 16:32:02 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7C0C71DB8043
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 16:32:02 +0900 (JST)
Date: Thu, 8 Mar 2012 16:30:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: revise the position of threshold index while
 unregistering event
Message-Id: <20120308163028.df8b6bde.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4F58599A.3090100@gmail.com>
References: <1331035943-7456-1-git-send-email-handai.szj@taobao.com>
	<20120308144448.889337cf.kamezawa.hiroyu@jp.fujitsu.com>
	<4F58599A.3090100@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, kirill@shutemov.name, Sha Zhengju <handai.szj@taobao.com>

On Thu, 08 Mar 2012 15:02:50 +0800
Sha Zhengju <handai.szj@gmail.com> wrote:

> On 03/08/2012 01:44 PM, KAMEZAWA Hiroyuki wrote:
> > On Tue,  6 Mar 2012 20:12:23 +0800
> > Sha Zhengju<handai.szj@gmail.com>  wrote:
> >
> >> From: Sha Zhengju<handai.szj@taobao.com>
> >>
> >> Index current_threshold should point to threshold just below or equal to usage.
> >> See below:
> >> http://www.spinics.net/lists/cgroups/msg00844.html
> >>
> >>
> >> Signed-off-by: Sha Zhengju<handai.szj@taobao.com>
> > Thank you for resending.
> >
> > Acked-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> >
> It's not a resending, though they are for the same reason.  May be I should
> merge them together ...
> 
Ah. Hmm..If your previous patch isn't picked up yet, could you send it again 
(or merge and post merged one ) ?

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
