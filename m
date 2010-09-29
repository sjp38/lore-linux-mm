Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6E0FD6B0047
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 16:30:19 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id o8TKUGje023643
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 13:30:16 -0700
Received: from pvg16 (pvg16.prod.google.com [10.241.210.144])
	by hpaq3.eem.corp.google.com with ESMTP id o8TKUE0v011494
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 13:30:15 -0700
Received: by pvg16 with SMTP id 16so399273pvg.26
        for <linux-mm@kvack.org>; Wed, 29 Sep 2010 13:30:14 -0700 (PDT)
Date: Wed, 29 Sep 2010 13:30:11 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/3] slub: Fix signedness warnings
In-Reply-To: <1285761735-31499-1-git-send-email-namhyung@gmail.com>
Message-ID: <alpine.DEB.2.00.1009291329400.9797@chino.kir.corp.google.com>
References: <1285761735-31499-1-git-send-email-namhyung@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Namhyung Kim <namhyung@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 29 Sep 2010, Namhyung Kim wrote:

> The bit-ops routines require its arg to be a pointer to unsigned long.
> This leads sparse to complain about different signedness as follows:
> 
>  mm/slub.c:2425:49: warning: incorrect type in argument 2 (different signedness)
>  mm/slub.c:2425:49:    expected unsigned long volatile *addr
>  mm/slub.c:2425:49:    got long *map
> 
> Signed-off-by: Namhyung Kim <namhyung@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
