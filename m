Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 047D46B0044
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 14:54:29 -0400 (EDT)
Received: by mail-vb0-f54.google.com with SMTP id q14so994807vbe.41
        for <linux-mm@kvack.org>; Mon, 29 Jul 2013 11:54:29 -0700 (PDT)
Message-ID: <51F6BA84.7060709@gmail.com>
Date: Mon, 29 Jul 2013 14:55:00 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [patch 1/6] arch: mm: remove obsolete init OOM protection
References: <1374791138-15665-1-git-send-email-hannes@cmpxchg.org> <1374791138-15665-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1374791138-15665-2-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, azurIt <azurit@pobox.sk>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@gmail.com

(7/25/13 6:25 PM), Johannes Weiner wrote:
> Back before smart OOM killing, when faulting tasks where killed
> directly on allocation failures, the arch-specific fault handlers
> needed special protection for the init process.
> 
> Now that all fault handlers call into the generic OOM killer (609838c
> "mm: invoke oom-killer from remaining unconverted page fault
> handlers"), which already provides init protection, the arch-specific
> leftovers can be removed.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Looks good to me.

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
