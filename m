Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 1D0136B005A
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 17:06:04 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so8629459pbb.14
        for <linux-mm@kvack.org>; Wed, 17 Oct 2012 14:06:03 -0700 (PDT)
Date: Wed, 17 Oct 2012 14:06:01 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: use IS_ENABLED(CONFIG_NUMA) instead of NUMA_BUILD
In-Reply-To: <1350302727-8372-1-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.DEB.2.00.1210171405490.20712@chino.kir.corp.google.com>
References: <1350302727-8372-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org

On Mon, 15 Oct 2012, Kirill A. Shutemov wrote:

> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> 
> We don't need custom NUMA_BUILD anymore, since we have handy
> IS_ENABLED().
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
