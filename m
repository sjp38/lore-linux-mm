Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id F210A9000DF
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 19:11:54 -0400 (EDT)
Received: by ywe9 with SMTP id 9so5217989ywe.14
        for <linux-mm@kvack.org>; Mon, 03 Oct 2011 16:11:52 -0700 (PDT)
Date: Mon, 3 Oct 2011 16:11:49 -0700
From: Andrew Morton <akpm00@gmail.com>
Subject: Re: [patch 00/10] memcg naturalization -rc4
Message-Id: <20111003161149.bc458294.akpm00@gmail.com>
In-Reply-To: <1317330064-28893-1-git-send-email-jweiner@redhat.com>
References: <1317330064-28893-1-git-send-email-jweiner@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 29 Sep 2011 23:00:54 +0200
Johannes Weiner <jweiner@redhat.com> wrote:

> this is the fourth revision of the memory cgroup naturalization
> series.

The patchset removes 20 lines from include/linux/*.h and removes
exactly zero lines from mm/*.c.  Freaky.

If we were ever brave/stupid emough to make
CONFIG_CGROUP_MEM_RES_CTLR=y unconditional, how much could we simplify
mm/?

We are adding bits of overhead to the  CONFIG_CGROUP_MEM_RES_CTLR=n case
all over the place.  This patchset actually decreases the size of allnoconfig
mm/built-in.o by 1/700th.

A "struct mem_cgroup" sometimes gets called "mem", sometimes "memcg",
sometimes "mem_cont".  Any more candidates?  Is there any logic to
this?


Anyway...  it all looks pretty sensible to me, but the timing (at
-rc8!) is terrible.  Please keep this material maintained for -rc1, OK?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
