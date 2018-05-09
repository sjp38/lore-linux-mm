Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id AAE9E6B05A0
	for <linux-mm@kvack.org>; Wed,  9 May 2018 19:31:04 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id s7-v6so58301pgp.15
        for <linux-mm@kvack.org>; Wed, 09 May 2018 16:31:04 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p11-v6si17981480plk.294.2018.05.09.16.31.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 May 2018 16:31:03 -0700 (PDT)
Date: Wed, 9 May 2018 16:31:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm/ksm: ignore STABLE_FLAG of rmap_item->address in
 rmap_walk_ksm
Message-Id: <20180509163101.02f23de1842a822c61fc68ff@linux-foundation.org>
In-Reply-To: <1525403506-6750-1-git-send-email-hejianet@gmail.com>
References: <20180503124415.3f9d38aa@p-imbrenda.boeblingen.de.ibm.com>
	<1525403506-6750-1-git-send-email-hejianet@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan@kernel.org>, Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>, Arvind Yadav <arvind.yadav.cs@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jia.he@hxt-semitech.com, Hugh Dickins <hughd@google.com>

On Fri,  4 May 2018 11:11:46 +0800 Jia He <hejianet@gmail.com> wrote:

> In our armv8a server(QDF2400), I noticed lots of WARN_ON caused by PAGE_SIZE
> unaligned for rmap_item->address under memory pressure tests(start 20 guests
> and run memhog in the host).
> 
> ...
> 
> In rmap_walk_ksm, the rmap_item->address might still have the STABLE_FLAG,
> then the start and end in handle_hva_to_gpa might not be PAGE_SIZE aligned.
> Thus it will cause exceptions in handle_hva_to_gpa on arm64.
> 
> This patch fixes it by ignoring(not removing) the low bits of address when
> doing rmap_walk_ksm.
> 
> Signed-off-by: jia.he@hxt-semitech.com

I assumed you wanted this patch to be committed as
From:jia.he@hxt-semitech.com rather than From:hejianet@gmail.com, so I
made that change.  Please let me know if this was inappropriate.

You can do this yourself by adding an explicit From: line to the very
start of the patch's email text.

Also, a storm of WARN_ONs is pretty poor behaviour.  Is that the only
misbehaviour which this bug causes?  Do you think the fix should be
backported into earlier kernels?
