Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CBC9B6B0073
	for <linux-mm@kvack.org>; Thu, 22 Oct 2009 15:52:35 -0400 (EDT)
Received: from spaceape14.eur.corp.google.com (spaceape14.eur.corp.google.com [172.28.16.148])
	by smtp-out.google.com with ESMTP id n9MJqWs5013746
	for <linux-mm@kvack.org>; Thu, 22 Oct 2009 20:52:32 +0100
Received: from pzk27 (pzk27.prod.google.com [10.243.19.155])
	by spaceape14.eur.corp.google.com with ESMTP id n9MJqTdi000708
	for <linux-mm@kvack.org>; Thu, 22 Oct 2009 12:52:29 -0700
Received: by pzk27 with SMTP id 27so3849521pzk.12
        for <linux-mm@kvack.org>; Thu, 22 Oct 2009 12:52:28 -0700 (PDT)
Date: Thu, 22 Oct 2009 12:52:27 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2 4/5] mm: add numa node symlink for cpu devices in
 sysfs
In-Reply-To: <20091022041525.15705.6794.stgit@bob.kio>
Message-ID: <alpine.DEB.2.00.0910221252020.26631@chino.kir.corp.google.com>
References: <20091022040814.15705.95572.stgit@bob.kio> <20091022041525.15705.6794.stgit@bob.kio>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alex Chiang <achiang@hp.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 21 Oct 2009, Alex Chiang wrote:

> You can discover which CPUs belong to a NUMA node by examining
> /sys/devices/system/node/node#/
> 
> However, it's not convenient to go in the other direction, when looking at
> /sys/devices/system/cpu/cpu#/
> 
> Yes, you can muck about in sysfs, but adding these symlinks makes
> life a lot more convenient.
> 
> Signed-off-by: Alex Chiang <achiang@hp.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
