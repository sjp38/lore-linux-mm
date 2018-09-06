Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4C8CF6B7802
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 05:15:40 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id g15-v6so3413631edm.11
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 02:15:40 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s19-v6si2848944edc.383.2018.09.06.02.15.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 02:15:39 -0700 (PDT)
Date: Thu, 6 Sep 2018 11:15:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 00/29] mm: remove bootmem allocator
Message-ID: <20180906091538.GN14951@dhcp22.suse.cz>
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul Burton <paul.burton@mips.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 05-09-18 18:59:15, Mike Rapoport wrote:
[...]
>  325 files changed, 846 insertions(+), 2478 deletions(-)
>  delete mode 100644 include/linux/bootmem.h
>  delete mode 100644 mm/bootmem.c
>  delete mode 100644 mm/nobootmem.c

This is really impressive! Thanks a lot for working on this. I wish we
could simplify the memblock API as well. There are just too many public
functions with subtly different semantic and barely any useful
documentation.

But even this is a great step forward!
-- 
Michal Hocko
SUSE Labs
