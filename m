Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E4D786B00E8
	for <linux-mm@kvack.org>; Wed, 12 Jan 2011 15:16:33 -0500 (EST)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p0CKGTia016985
	for <linux-mm@kvack.org>; Wed, 12 Jan 2011 12:16:29 -0800
Received: from pwi7 (pwi7.prod.google.com [10.241.219.7])
	by hpaq2.eem.corp.google.com with ESMTP id p0CKGRWX009772
	for <linux-mm@kvack.org>; Wed, 12 Jan 2011 12:16:27 -0800
Received: by pwi7 with SMTP id 7so163760pwi.3
        for <linux-mm@kvack.org>; Wed, 12 Jan 2011 12:16:26 -0800 (PST)
Date: Wed, 12 Jan 2011 12:16:24 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] Rename struct task variables from p to tsk
In-Reply-To: <1294845571-11529-1-git-send-email-emunson@mgebm.net>
Message-ID: <alpine.DEB.2.00.1101121215370.31521@chino.kir.corp.google.com>
References: <1294845571-11529-1-git-send-email-emunson@mgebm.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <emunson@mgebm.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 12 Jan 2011, Eric B Munson wrote:

> p is not a meaningful identifier, this patch replaces all instances
> in page_alloc.c of p when used as a struct task with the more useful
> tsk.
> 

mm-page_allocc-dont-cache-current-in-a-local.patch removes all of the 
stack allocations changed in this patch, so it's not needed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
