Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 2F3E76B0038
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 18:43:29 -0400 (EDT)
Received: by pdbnk13 with SMTP id nk13so143197114pdb.0
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 15:43:28 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id c7si31780250pdn.193.2015.04.27.15.43.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Apr 2015 15:43:28 -0700 (PDT)
Date: Mon, 27 Apr 2015 15:43:27 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 03/13] mm: meminit: Only set page reserved in the
 memblock region
Message-Id: <20150427154327.f7326dc16649ae402b5b5dd3@linux-foundation.org>
In-Reply-To: <1429785196-7668-4-git-send-email-mgorman@suse.de>
References: <1429785196-7668-1-git-send-email-mgorman@suse.de>
	<1429785196-7668-4-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, LKML <linux-kernel@vger.kernel.org>

On Thu, 23 Apr 2015 11:33:06 +0100 Mel Gorman <mgorman@suse.de> wrote:

> From: Nathan Zimmer <nzimmer@sgi.com>
> 
> Currently we when we initialze each page struct is set as reserved upon
> initialization.

Hard to parse.  I changed it to "Currently each page struct is set as
reserved upon initialization".

>  This changes to starting with the reserved bit clear and
> then only setting the bit in the reserved region.

For what reason?

A code comment over reserve_bootmem_region() would be a good way
to answer that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
