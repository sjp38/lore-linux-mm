Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 523926B025E
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 05:23:55 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id b81so96727292lfe.1
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 02:23:55 -0700 (PDT)
Received: from bes.se.axis.com (bes.se.axis.com. [195.60.68.10])
        by mx.google.com with ESMTP id k125si17962633lfg.178.2016.10.17.02.23.53
        for <linux-mm@kvack.org>;
        Mon, 17 Oct 2016 02:23:54 -0700 (PDT)
Date: Mon, 17 Oct 2016 11:23:52 +0200
From: Jesper Nilsson <jesper.nilsson@axis.com>
Subject: Re: [PATCH 10/10] mm: replace access_process_vm() write parameter
 with gup_flags
Message-ID: <20161017092352.GH30704@axis.com>
References: <20161013002020.3062-1-lstoakes@gmail.com>
 <20161013002020.3062-11-lstoakes@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161013002020.3062-11-lstoakes@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lorenzo Stoakes <lstoakes@gmail.com>
Cc: linux-mm@kvack.org, linux-mips@linux-mips.org, linux-fbdev@vger.kernel.org, Jan Kara <jack@suse.cz>, kvm@vger.kernel.org, linux-sh@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, dri-devel@lists.freedesktop.org, netdev@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-scsi@vger.kernel.org, linux-rdma@vger.kernel.org, x86@kernel.org, Hugh Dickins <hughd@google.com>, linux-media@vger.kernel.org, Rik van Riel <riel@redhat.com>, intel-gfx@lists.freedesktop.org, adi-buildroot-devel@lists.sourceforge.net, ceph-devel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-cris-kernel@axis.com, Linus Torvalds <torvalds@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-security-module@vger.kernel.org, linux-alpha@vger.kernel.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>

On Thu, Oct 13, 2016 at 01:20:20AM +0100, Lorenzo Stoakes wrote:
> This patch removes the write parameter from access_process_vm() and replaces it
> with a gup_flags parameter as use of this function previously _implied_
> FOLL_FORCE, whereas after this patch callers explicitly pass this flag.
> 
> We make this explicit as use of FOLL_FORCE can result in surprising behaviour
> (and hence bugs) within the mm subsystem.
> 
> Signed-off-by: Lorenzo Stoakes <lstoakes@gmail.com>
> ---
>  arch/cris/arch-v32/kernel/ptrace.c |  4 ++--

For the CRIS part:

Acked-by: Jesper Nilsson <jesper.nilsson@axis.com>

/^JN - Jesper Nilsson
-- 
               Jesper Nilsson -- jesper.nilsson@axis.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
