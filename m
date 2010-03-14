Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0F9586B00DA
	for <linux-mm@kvack.org>; Sun, 14 Mar 2010 19:19:04 -0400 (EDT)
Received: from spaceape8.eur.corp.google.com (spaceape8.eur.corp.google.com [172.28.16.142])
	by smtp-out.google.com with ESMTP id o2ENJ0Z7022358
	for <linux-mm@kvack.org>; Sun, 14 Mar 2010 23:19:01 GMT
Received: from pxi42 (pxi42.prod.google.com [10.243.27.42])
	by spaceape8.eur.corp.google.com with ESMTP id o2ENIwnQ000349
	for <linux-mm@kvack.org>; Sun, 14 Mar 2010 16:18:59 -0700
Received: by pxi42 with SMTP id 42so1069134pxi.26
        for <linux-mm@kvack.org>; Sun, 14 Mar 2010 16:18:58 -0700 (PDT)
Date: Sun, 14 Mar 2010 16:18:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mempolicy: remove redundant code
In-Reply-To: <1268567418-8700-1-git-send-email-user@bob-laptop>
Message-ID: <alpine.DEB.2.00.1003141618001.32212@chino.kir.corp.google.com>
References: <1268567418-8700-1-git-send-email-user@bob-laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Sun, 14 Mar 2010, Bob Liu wrote:

> From: Bob Liu <lliubbo@gmail.com>
> 
> 1. In funtion is_valid_nodemask(), varibable k will be inited to 0 in
> the following loop, needn't init to policy_zone anymore.
> 
> 2. (MPOL_F_STATIC_NODES | MPOL_F_RELATIVE_NODES) has already defined
> to MPOL_MODE_FLAGS in mempolicy.h.

Acked-by: David Rientjes <rientjes@google.com>

> ---
>  mempolicy.c |    5 +----
>  1 files changed, 1 insertions(+), 4 deletions(-)
> 

(although the diffstat still doesn't have the mm/ path).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
