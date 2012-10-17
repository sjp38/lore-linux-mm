Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 0F1386B005A
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 17:07:38 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so8630926pbb.14
        for <linux-mm@kvack.org>; Wed, 17 Oct 2012 14:07:37 -0700 (PDT)
Date: Wed, 17 Oct 2012 14:07:35 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: use IS_ENABLED(CONFIG_COMPACTION) instead of
 COMPACTION_BUILD
In-Reply-To: <1350302735-8416-1-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.DEB.2.00.1210171407240.20712@chino.kir.corp.google.com>
References: <1350302735-8416-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org

On Mon, 15 Oct 2012, Kirill A. Shutemov wrote:

> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> 
> We don't need custom COMPACTION_BUILD anymore, since we have handy
> IS_ENABLED().
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
