Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 3B68C6B0047
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 20:38:43 -0400 (EDT)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id o8T0cdY2000775
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 17:38:41 -0700
Received: from pvh1 (pvh1.prod.google.com [10.241.210.193])
	by kpbe14.cbf.corp.google.com with ESMTP id o8T0bcDr023415
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 17:38:37 -0700
Received: by pvh1 with SMTP id 1so68166pvh.9
        for <linux-mm@kvack.org>; Tue, 28 Sep 2010 17:38:37 -0700 (PDT)
Date: Tue, 28 Sep 2010 17:38:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [Slub cleanup5 3/3] slub: extract common code to remove objects
 from partial list without locking
In-Reply-To: <20100928131057.767067382@linux.com>
Message-ID: <alpine.DEB.2.00.1009281738200.13787@chino.kir.corp.google.com>
References: <20100928131025.319846721@linux.com> <20100928131057.767067382@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 28 Sep 2010, Christoph Lameter wrote:

> There are a couple of places where repeat the same statements when removing
> a page from the partial list. Consolidate that into __remove_partial().
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
