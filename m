Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7E5606B00EE
	for <linux-mm@kvack.org>; Sun, 24 Jul 2011 23:08:20 -0400 (EDT)
Received: by qwa26 with SMTP id 26so2673395qwa.14
        for <linux-mm@kvack.org>; Sun, 24 Jul 2011 20:08:18 -0700 (PDT)
From: Ben Gamari <bgamari.foss@gmail.com>
Subject: Re: [PATCH v4 4/7] Reclaim invalidated page ASAP
In-Reply-To: <AANLkTikT_HNvuBR0J-2COgB54gquj2FineOjkzU+mt6_@mail.gmail.com>
References: <cover.1291568905.git.minchan.kim@gmail.com> <0724024711222476a0c8deadb5b366265b8e5824.1291568905.git.minchan.kim@gmail.com> <20101208170504.1750.A69D9226@jp.fujitsu.com> <AANLkTikG1EAMm8yPvBVUXjFz1Bu9m+vfwH3TRPDzS9mq@mail.gmail.com> <87oc8wa063.fsf@gmail.com> <AANLkTin642NFLMubtCQhSVUNLzfdk5ajz-RWe2zT+Lw6@mail.gmail.com> <20101213153105.GA2344@barrios-desktop> <87lj3t30a9.fsf@gmail.com> <AANLkTikT_HNvuBR0J-2COgB54gquj2FineOjkzU+mt6_@mail.gmail.com>
Date: Sun, 24 Jul 2011 23:08:10 -0400
Message-ID: <87vcurrrad.fsf@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>

On Tue, 14 Dec 2010 11:36:12 +0900, Minchan Kim <minchan.kim@gmail.com> wrote:
> Hi Ben,
> 
> [snipped]

What exactly happened to this set? It seems it dropped off my radar and
otherwise never was merged. Was it not tested enough, the benefit not
great enough, or did it simply slip through the cracks?

Cheers,

- Ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
