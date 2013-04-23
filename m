Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id D64356B0002
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 19:16:46 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so345777pdi.33
        for <linux-mm@kvack.org>; Tue, 23 Apr 2013 16:16:46 -0700 (PDT)
Date: Tue, 23 Apr 2013 16:16:44 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [Patch v2] mm: slab: Verify the nodeid passed to
 ____cache_alloc_node
In-Reply-To: <1014891011.990074.1366727496599.JavaMail.root@redhat.com>
Message-ID: <alpine.DEB.2.02.1304231616270.3855@chino.kir.corp.google.com>
References: <1014891011.990074.1366727496599.JavaMail.root@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Tomlin <atomlin@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux.com, penberg@kernel.org, Rik <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>

On Tue, 23 Apr 2013, Aaron Tomlin wrote:

> mm: slab: Verify the nodeid passed to ____cache_alloc_node
>     
> If the nodeid is > num_online_nodes() this can cause an
> Oops and a panic(). The purpose of this patch is to assert
> if this condition is true to aid debugging efforts rather
> than some random NULL pointer dereference or page fault.
>     
> Signed-off-by: Aaron Tomlin <atomlin@redhat.com>
> Reviewed-by: Rik van Riel <riel@redhat.com>
> 

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
