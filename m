Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D14376B0087
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 18:09:13 -0500 (EST)
Received: by ywo7 with SMTP id 7so2692ywo.14
        for <linux-mm@kvack.org>; Tue, 09 Nov 2010 15:09:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1289294671-6865-3-git-send-email-gthelen@google.com>
References: <1289294671-6865-1-git-send-email-gthelen@google.com>
	<1289294671-6865-3-git-send-email-gthelen@google.com>
Date: Wed, 10 Nov 2010 08:09:06 +0900
Message-ID: <AANLkTi=Nd6qy5S0zLUN80iEhQab3rGK77waVihEhN4ia@mail.gmail.com>
Subject: Re: [PATCH 2/6] memcg: pass mem_cgroup to mem_cgroup_dirty_info()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Nov 9, 2010 at 6:24 PM, Greg Thelen <gthelen@google.com> wrote:
> Pass mem_cgroup parameter through memcg_dirty_info() into
> mem_cgroup_dirty_info(). =A0This allows for querying dirty memory
> information from a particular cgroup, rather than just the
> current task's cgroup.
>
> Signed-off-by: Greg Thelen <gthelen@google.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
