Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 558166B13F2
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 02:22:58 -0500 (EST)
Received: by vcbf13 with SMTP id f13so4131427vcb.14
        for <linux-mm@kvack.org>; Mon, 13 Feb 2012 23:22:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120214121515.34281b73.kamezawa.hiroyu@jp.fujitsu.com>
References: <20120214120414.025625c2.kamezawa.hiroyu@jp.fujitsu.com> <20120214121515.34281b73.kamezawa.hiroyu@jp.fujitsu.com>
From: Greg Thelen <gthelen@google.com>
Date: Mon, 13 Feb 2012 23:22:37 -0800
Message-ID: <CAHH2K0aWdLM523b9VnqJuW_c_rvR7-ZCDEGmzJWfo6g5pj7Cbw@mail.gmail.com>
Subject: Re: [PATCH 5/6 v4] memcg: remove PCG_FILE_MAPPED
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>

On Mon, Feb 13, 2012 at 7:15 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> From 96407a510d5212179a4768f28591b35d5c17d403 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Thu, 2 Feb 2012 15:02:18 +0900
> Subject: [PATCH 5/6] memcg: remove PCG_FILE_MAPPED
>
> with new lock scheme for updating memcg's page stat, we don't need
> a flag PCG_FILE_MAPPED which was duplicated information of page_mapped().
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Thanks!

Acked-by: Greg Thelen <gthelen@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
