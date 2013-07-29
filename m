Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 8B93E6B005A
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 15:00:28 -0400 (EDT)
Received: by mail-ve0-f176.google.com with SMTP id b10so1179610vea.35
        for <linux-mm@kvack.org>; Mon, 29 Jul 2013 12:00:27 -0700 (PDT)
Message-ID: <51F6BBEC.5070203@gmail.com>
Date: Mon, 29 Jul 2013 15:01:00 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [patch 4/6] x86: finish user fault error path with fatal signal
References: <1374791138-15665-1-git-send-email-hannes@cmpxchg.org> <1374791138-15665-5-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1374791138-15665-5-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, azurIt <azurit@pobox.sk>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@gmail.com

(7/25/13 6:25 PM), Johannes Weiner wrote:
> The x86 fault handler bails in the middle of error handling when the
> task has a fatal signal pending.  For a subsequent patch this is a
> problem in OOM situations because it relies on
> pagefault_out_of_memory() being called even when the task has been
> killed, to perform proper per-task OOM state unwinding.
> 
> Shortcutting the fault like this is a rather minor optimization that
> saves a few instructions in rare cases.  Just remove it for
> user-triggered faults.
> 
> Use the opportunity to split the fault retry handling from actual
> fault errors and add locking documentation that reads suprisingly
> similar to ARM's.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
