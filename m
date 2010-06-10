Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 962AC6B0071
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 16:23:10 -0400 (EDT)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id o5AKN4Nn008834
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 13:23:04 -0700
Received: from pvc30 (pvc30.prod.google.com [10.241.209.158])
	by kpbe19.cbf.corp.google.com with ESMTP id o5AKN3mQ024189
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 13:23:03 -0700
Received: by pvc30 with SMTP id 30so154635pvc.6
        for <linux-mm@kvack.org>; Thu, 10 Jun 2010 13:23:02 -0700 (PDT)
Date: Thu, 10 Jun 2010 13:23:01 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] Cleanup : change try_set_zone_oom with
 try_set_zonelist_oom
In-Reply-To: <1276177124-3395-1-git-send-email-minchan.kim@gmail.com>
Message-ID: <alpine.DEB.2.00.1006101322460.20197@chino.kir.corp.google.com>
References: <1276177124-3395-1-git-send-email-minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 10 Jun 2010, Minchan Kim wrote:

> We have been used naming try_set_zone_oom and clear_zonelist_oom.
> The role of functions is to lock of zonelist for preventing parallel
> OOM. So clear_zonelist_oom makes sense but try_set_zone_oome is rather
> awkward and unmatched with clear_zonelist_oom.
> 
> Let's change it with try_set_zonelist_oom.
> 
> Cc: David Rientjes <rientjes@google.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Let's change it with try_set_zonelist_oom.
> 
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
