Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B79468D0039
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 07:43:04 -0500 (EST)
Date: Thu, 10 Feb 2011 13:42:53 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 0/4] memcg: operate on page quantities internally
Message-ID: <20110210124253.GO27110@cmpxchg.org>
References: <1297249313-23746-1-git-send-email-hannes@cmpxchg.org>
 <20110210085034.a6c5d703.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110210085034.a6c5d703.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Feb 10, 2011 at 08:50:34AM +0900, KAMEZAWA Hiroyuki wrote:
> On Wed,  9 Feb 2011 12:01:49 +0100
> Johannes Weiner <hannes@cmpxchg.org> wrote:
> > If I did not miss anything, this should leave only res_counter and
> > user-visible stuff in bytes.  The ABI probably won't change, so next
> > up is converting res_counter to operate on page quantities.
> 
> Hmm, I think this should be done but think this should be postphoned, too.
> Because, IIUC, some guys will try to discuss charging against kernel objects
> in the next mm-summit. IMHO, it will be done against PAGE not against
> Object even if we do kernel object accouting. So this patch is okay for me.
> But I think it's better to go ahead after we confirm the way we go.
> How do you think ?

That makes sense, let's leave res_counter alone until we have hashed
this out.

> Anyway, I welcome this patch.

Thanks for reviewing,

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
