Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 33A326B015B
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 15:37:21 -0500 (EST)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id o2CKbG24020235
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 20:37:17 GMT
Received: from pxi39 (pxi39.prod.google.com [10.243.27.39])
	by wpaz17.hot.corp.google.com with ESMTP id o2CKbEmm005260
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 12:37:15 -0800
Received: by pxi39 with SMTP id 39so1005374pxi.2
        for <linux-mm@kvack.org>; Fri, 12 Mar 2010 12:37:14 -0800 (PST)
Date: Fri, 12 Mar 2010 12:37:10 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [Patch] mempolicy: remove redundant code
In-Reply-To: <cf18f8341003120224k243ff3fdq6d4a7acfe15dccc8@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1003121236060.13400@chino.kir.corp.google.com>
References: <cf18f8341003120224k243ff3fdq6d4a7acfe15dccc8@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Fri, 12 Mar 2010, Bob Liu wrote:

> 1. In funtion is_valid_nodemask(), varibable k will be inited to 0 in
> the following loop, needn't init to policy_zone anymore.
> 
> 2. (MPOL_F_STATIC_NODES | MPOL_F_RELATIVE_NODES) has already defined
> to MPOL_MODE_FLAGS in mempolicy.h.
> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>

I like your patch, but it has whitespace damage.  Would it be possible to 
read the gmail section of Documentation/email-clients.txt and try to 
repropose it?  Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
