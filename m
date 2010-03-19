Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0D8096B00BA
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 04:48:32 -0400 (EDT)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [10.3.21.5])
	by smtp-out.google.com with ESMTP id o2J8mQPw014152
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 09:48:26 +0100
Received: from pwj1 (pwj1.prod.google.com [10.241.219.65])
	by hpaq5.eem.corp.google.com with ESMTP id o2J8mOOK017637
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 09:48:24 +0100
Received: by pwj1 with SMTP id 1so2407061pwj.37
        for <linux-mm@kvack.org>; Fri, 19 Mar 2010 01:48:23 -0700 (PDT)
Date: Fri, 19 Mar 2010 01:48:22 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] mempolicy:del case MPOL_INTERLEAVE in
 policy_zonelist()
In-Reply-To: <1268916376-8695-1-git-send-email-user@bob-laptop>
Message-ID: <alpine.DEB.2.00.1003190148060.26509@chino.kir.corp.google.com>
References: <1268916376-8695-1-git-send-email-user@bob-laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Thu, 18 Mar 2010, Bob Liu wrote:

> From: Bob Liu <lliubbo@gmail.com>
> 
> In policy_zonelist() mode MPOL_INTERLEAVE shouldn't happen,
> so fall through to BUG() instead of break to return.I also fix
> the comment.
> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
