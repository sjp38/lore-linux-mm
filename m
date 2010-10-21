Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 372B15F0040
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 16:26:13 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id o9LKFSBa003790
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 13:15:28 -0700
Received: from pwj5 (pwj5.prod.google.com [10.241.219.69])
	by wpaz21.hot.corp.google.com with ESMTP id o9LKF4vc014686
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 13:15:27 -0700
Received: by pwj5 with SMTP id 5so165976pwj.1
        for <linux-mm@kvack.org>; Thu, 21 Oct 2010 13:15:27 -0700 (PDT)
Date: Thu, 21 Oct 2010 13:15:22 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: slub: move slabinfo.c to tools/slub/slabinfo.c
In-Reply-To: <alpine.DEB.2.00.1010211300550.24115@router.home>
Message-ID: <alpine.DEB.2.00.1010211315070.14946@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1010211300550.24115@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 21 Oct 2010, Christoph Lameter wrote:

> We now have a tools directory for these things.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
