Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 22AF66B006E
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 18:43:46 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so143182059pdb.1
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 15:43:45 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id kw15si31766287pab.203.2015.04.27.15.43.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Apr 2015 15:43:45 -0700 (PDT)
Date: Mon, 27 Apr 2015 15:43:44 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 07/13] mm: meminit: Initialise a subset of struct pages
 if CONFIG_DEFERRED_STRUCT_PAGE_INIT is set
Message-Id: <20150427154344.421fd9f151bf27d365d02fd2@linux-foundation.org>
In-Reply-To: <1429785196-7668-8-git-send-email-mgorman@suse.de>
References: <1429785196-7668-1-git-send-email-mgorman@suse.de>
	<1429785196-7668-8-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, LKML <linux-kernel@vger.kernel.org>

On Thu, 23 Apr 2015 11:33:10 +0100 Mel Gorman <mgorman@suse.de> wrote:

> This patch initalises all low memory struct pages and 2G of the highest zone
> on each node during memory initialisation if CONFIG_DEFERRED_STRUCT_PAGE_INIT
> is set. That config option cannot be set but will be available in a later
> patch.  Parallel initialisation of struct page depends on some features
> from memory hotplug and it is necessary to alter alter section annotations.
> 
>  ...
>
> +#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
> +#define __defermem_init __meminit
> +#define __defer_init    __meminit
> +#else
> +#define __defermem_init
> +#define __defer_init __init
> +#endif

Could we get some comments describing these?  What they do, when and
where they should be used.  I have a suspicion that the naming isn't
good, but I didn't spend a lot of time reverse-engineering the
intent...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
