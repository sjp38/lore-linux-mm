Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id E739E6B0031
	for <linux-mm@kvack.org>; Sat,  7 Sep 2013 21:43:35 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id xa7so4729298pbc.3
        for <linux-mm@kvack.org>; Sat, 07 Sep 2013 18:43:35 -0700 (PDT)
Date: Sat, 7 Sep 2013 18:43:33 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] vmpressure: fix divide-by-0 in vmpressure_work_fn
In-Reply-To: <alpine.LNX.2.00.1309062254470.11420@eggly.anvils>
Message-ID: <alpine.DEB.2.02.1309071843230.8326@chino.kir.corp.google.com>
References: <alpine.LNX.2.00.1309062254470.11420@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Anton Vorontsov <anton.vorontsov@linaro.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 6 Sep 2013, Hugh Dickins wrote:

> Hit divide-by-0 in vmpressure_work_fn(): checking vmpr->scanned before
> taking the lock is not enough, we must check scanned afterwards too.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Cc: stable@vger.kernel.org

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
