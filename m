Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 296C56B0333
	for <linux-mm@kvack.org>; Mon, 27 Mar 2017 09:13:27 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id c72so24541804lfh.22
        for <linux-mm@kvack.org>; Mon, 27 Mar 2017 06:13:27 -0700 (PDT)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id s125si278841lja.215.2017.03.27.06.13.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Mar 2017 06:13:25 -0700 (PDT)
Received: by mail-lf0-x242.google.com with SMTP id n78so7141126lfi.3
        for <linux-mm@kvack.org>; Mon, 27 Mar 2017 06:13:25 -0700 (PDT)
Date: Mon, 27 Mar 2017 16:13:22 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 5/6] x86/xen: Change __xen_pgd_walk() and
 xen_cleanmfnmap() to support p4d
Message-ID: <20170327131322.3xroyjqeerb37f3d@node.shutemov.name>
References: <20170317185515.8636-1-kirill.shutemov@linux.intel.com>
 <20170317185515.8636-6-kirill.shutemov@linux.intel.com>
 <20170327063423.GA13876@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170327063423.GA13876@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Xiong Zhang <xiong.y.zhang@intel.com>

On Mon, Mar 27, 2017 at 08:34:23AM +0200, Ingo Molnar wrote:
> y
> * Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:
> 
> > Split these helpers into few per-level functions and add support of
> > additional page table level.
> > 
> > Signed-off-by: Xiong Zhang <xiong.y.zhang@intel.com>
> > [kirill.shutemov@linux.intel.com: split off into separate patch]
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> 
> So who's the primary author of this patch, you or Xiong Zhang? If the latter then 
> a "From: " line is missing. For now I've added the missing "From" line.

Xiong is author of the changes. I've writetten commit message.

So, you're right, "From:" is missing.

Thanks.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
