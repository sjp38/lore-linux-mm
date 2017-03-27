Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 343756B0333
	for <linux-mm@kvack.org>; Mon, 27 Mar 2017 02:34:28 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id s66so34132010wrc.15
        for <linux-mm@kvack.org>; Sun, 26 Mar 2017 23:34:28 -0700 (PDT)
Received: from mail-wr0-x243.google.com (mail-wr0-x243.google.com. [2a00:1450:400c:c0c::243])
        by mx.google.com with ESMTPS id p71si12961207wma.64.2017.03.26.23.34.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Mar 2017 23:34:26 -0700 (PDT)
Received: by mail-wr0-x243.google.com with SMTP id p52so6937105wrc.2
        for <linux-mm@kvack.org>; Sun, 26 Mar 2017 23:34:26 -0700 (PDT)
Date: Mon, 27 Mar 2017 08:34:23 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 5/6] x86/xen: Change __xen_pgd_walk() and
 xen_cleanmfnmap() to support p4d
Message-ID: <20170327063423.GA13876@gmail.com>
References: <20170317185515.8636-1-kirill.shutemov@linux.intel.com>
 <20170317185515.8636-6-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170317185515.8636-6-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Xiong Zhang <xiong.y.zhang@intel.com>

y
* Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:

> Split these helpers into few per-level functions and add support of
> additional page table level.
> 
> Signed-off-by: Xiong Zhang <xiong.y.zhang@intel.com>
> [kirill.shutemov@linux.intel.com: split off into separate patch]
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

So who's the primary author of this patch, you or Xiong Zhang? If the latter then 
a "From: " line is missing. For now I've added the missing "From" line.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
