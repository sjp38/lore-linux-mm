Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8D9AA6B006A
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 15:51:26 -0500 (EST)
Received: from spaceape8.eur.corp.google.com (spaceape8.eur.corp.google.com [172.28.16.142])
	by smtp-out.google.com with ESMTP id o0DKpMEB000710
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 12:51:23 -0800
Received: from pzk31 (pzk31.prod.google.com [10.243.19.159])
	by spaceape8.eur.corp.google.com with ESMTP id o0DKneFQ006405
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 12:51:21 -0800
Received: by pzk31 with SMTP id 31so2190570pzk.28
        for <linux-mm@kvack.org>; Wed, 13 Jan 2010 12:51:21 -0800 (PST)
Date: Wed, 13 Jan 2010 12:51:16 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] hugetlb: Fix section mismatches #2
In-Reply-To: <4B4DE0C1.7080709@suse.com>
Message-ID: <alpine.DEB.2.00.1001131250510.24847@chino.kir.corp.google.com>
References: <20100113004855.550486769@suse.com> <20100113004938.715904356@suse.com> <alpine.DEB.2.00.1001130127450.469@chino.kir.corp.google.com> <4B4DE0C1.7080709@suse.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Jeff Mahoney <jeffm@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, 13 Jan 2010, Jeff Mahoney wrote:

>  hugetlb_register_node calls hugetlb_sysfs_add_hstate, which is marked with
>  __init. Since hugetlb_register_node is only called by
>  hugetlb_register_all_nodes, which in turn is only called by hugetlb_init,
>  it's safe to mark both of them as __init.
> 
> Signed-off-by: Jeff Mahoney <jeffm@suse.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
