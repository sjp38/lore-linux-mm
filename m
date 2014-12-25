Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id C00586B006C
	for <linux-mm@kvack.org>; Fri, 26 Dec 2014 11:00:26 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kq14so13406371pab.34
        for <linux-mm@kvack.org>; Fri, 26 Dec 2014 08:00:26 -0800 (PST)
Received: from sym2.noone.org (sym2.noone.org. [2a01:4f8:120:4161::3])
        by mx.google.com with ESMTP id d19si37251187wib.37.2014.12.25.04.30.16
        for <linux-mm@kvack.org>;
        Thu, 25 Dec 2014 04:30:16 -0800 (PST)
Date: Thu, 25 Dec 2014 13:30:15 +0100
From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH 26/38] nios2: drop _PAGE_FILE and pte_file()-related
 helpers
Message-ID: <20141225123014.GO16916@distanz.ch>
References: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1419423766-114457-27-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1419423766-114457-27-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: akpm@linux-foundation.org, peterz@infradead.org, mingo@kernel.org, davej@redhat.com, sasha.levin@oracle.com, hughd@google.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Ley Foon Tan <lftan@altera.com>

On 2014-12-24 at 13:22:34 +0100, Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:
> We've replaced remap_file_pages(2) implementation with emulation.
> Nobody creates non-linear mapping anymore.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Ley Foon Tan <lftan@altera.com>

Reviewed-by: Tobias Klauser <tklauser@distanz.ch>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
