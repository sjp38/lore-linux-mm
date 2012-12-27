Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 465646B005A
	for <linux-mm@kvack.org>; Thu, 27 Dec 2012 17:28:16 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id e20so4492900dak.14
        for <linux-mm@kvack.org>; Thu, 27 Dec 2012 14:28:15 -0800 (PST)
Date: Thu, 27 Dec 2012 14:28:13 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/3] mm, sparse: don't check return value of alloc_bootmem
 calls
In-Reply-To: <1356293711-23864-3-git-send-email-sasha.levin@oracle.com>
Message-ID: <alpine.DEB.2.00.1212271428020.18214@chino.kir.corp.google.com>
References: <1356293711-23864-1-git-send-email-sasha.levin@oracle.com> <1356293711-23864-3-git-send-email-sasha.levin@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Gavin Shan <shangw@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, 23 Dec 2012, Sasha Levin wrote:

> There's no need to check the result of alloc_bootmem() functions since
> they'll panic if allocation fails.
> 
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
