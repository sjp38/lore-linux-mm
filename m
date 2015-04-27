Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 065136B0071
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 18:43:58 -0400 (EDT)
Received: by pdbqd1 with SMTP id qd1so143307479pdb.2
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 15:43:57 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id pl10si31686040pbb.188.2015.04.27.15.43.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Apr 2015 15:43:57 -0700 (PDT)
Date: Mon, 27 Apr 2015 15:43:56 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 11/13] mm: meminit: Free pages in large chunks where
 possible
Message-Id: <20150427154356.67e3d186b732a2c2b00e49cb@linux-foundation.org>
In-Reply-To: <1429785196-7668-12-git-send-email-mgorman@suse.de>
References: <1429785196-7668-1-git-send-email-mgorman@suse.de>
	<1429785196-7668-12-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, LKML <linux-kernel@vger.kernel.org>

On Thu, 23 Apr 2015 11:33:14 +0100 Mel Gorman <mgorman@suse.de> wrote:

> Parallel struct page frees pages one at a time. Try free pages as single
> large pages where possible.
> 
> ...
>
>  void __defermem_init deferred_init_memmap(int nid)

This function is gruesome in an 80-col display.  Even the code comments
wrap, which is nuts.  Maybe hoist the contents of the outermost loop
into a separate function, called for each zone?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
