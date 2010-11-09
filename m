Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 695856B004A
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 18:36:31 -0500 (EST)
Received: by iwn9 with SMTP id 9so27618iwn.14
        for <linux-mm@kvack.org>; Tue, 09 Nov 2010 15:36:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1289294671-6865-5-git-send-email-gthelen@google.com>
References: <1289294671-6865-1-git-send-email-gthelen@google.com>
	<1289294671-6865-5-git-send-email-gthelen@google.com>
Date: Wed, 10 Nov 2010 08:36:29 +0900
Message-ID: <AANLkTinG7CY3VcWmWQBzNyUu0GKy-ZGKmaLWzRMA_poH@mail.gmail.com>
Subject: Re: [PATCH 4/6] memcg: simplify mem_cgroup_page_stat()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Nov 9, 2010 at 6:24 PM, Greg Thelen <gthelen@google.com> wrote:
> The cgroup given to mem_cgroup_page_stat() is no allowed to be
> NULL or the root cgroup. =A0So there is no need to complicate the code
> handling those cases.
>
> Signed-off-by: Greg Thelen <gthelen@google.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

You already did what i want. :)
I should have commented after seeing all patches.

Thanks.
--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
