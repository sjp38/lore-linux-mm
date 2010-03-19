Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9C1C56B00BC
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 04:50:13 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id o2J8oAdn032594
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 01:50:10 -0700
Received: from pwi7 (pwi7.prod.google.com [10.241.219.7])
	by wpaz9.hot.corp.google.com with ESMTP id o2J8o8fx004946
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 01:50:09 -0700
Received: by pwi7 with SMTP id 7so2171462pwi.35
        for <linux-mm@kvack.org>; Fri, 19 Mar 2010 01:50:08 -0700 (PDT)
Date: Fri, 19 Mar 2010 01:50:05 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RESEND][PATCH 2/2] mempolicy: remove redundant check
In-Reply-To: <1268918431-9686-1-git-send-email-user@bob-laptop>
Message-ID: <alpine.DEB.2.00.1003190149490.26509@chino.kir.corp.google.com>
References: <1268918431-9686-1-git-send-email-user@bob-laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Thu, 18 Mar 2010, Bob Liu wrote:

> From: Bob Liu <lliubbo@gmail.com>
> 
> Lee's patch "mempolicy: use MPOL_PREFERRED for system-wide
> default policy" has made the MPOL_DEFAULT only used in the
> memory policy APIs. So, no need to check in __mpol_equal also.
> Also get rid of mpol_match_intent() and move its logic directly
> into __mpol_equal().
> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
