Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id B35366B0038
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 08:43:11 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id f134so10896757lfg.6
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 05:43:11 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i2si10603427wjm.278.2016.10.18.05.43.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 18 Oct 2016 05:43:10 -0700 (PDT)
Date: Tue, 18 Oct 2016 14:43:05 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 01/10] mm: remove write/force parameters from
 __get_user_pages_locked()
Message-ID: <20161018124305.GA29967@quack2.suse.cz>
References: <20161013002020.3062-1-lstoakes@gmail.com>
 <20161013002020.3062-2-lstoakes@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161013002020.3062-2-lstoakes@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lorenzo Stoakes <lstoakes@gmail.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, adi-buildroot-devel@lists.sourceforge.net, ceph-devel@vger.kernel.org, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, kvm@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-cris-kernel@axis.com, linux-fbdev@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mips@linux-mips.org, linux-rdma@vger.kernel.org, linux-s390@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-scsi@vger.kernel.org, linux-security-module@vger.kernel.org, linux-sh@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org

On Thu 13-10-16 01:20:11, Lorenzo Stoakes wrote:
> This patch removes the write and force parameters from __get_user_pages_locked()
> to make the use of FOLL_FORCE explicit in callers as use of this flag can result
> in surprising behaviour (and hence bugs) within the mm subsystem.
> 
> Signed-off-by: Lorenzo Stoakes <lstoakes@gmail.com>

Looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
