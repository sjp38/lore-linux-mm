Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3E5AE6B02B4
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 01:45:29 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 80so6697324wmt.15
        for <linux-mm@kvack.org>; Sun, 16 Jul 2017 22:45:29 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e69si8747023wme.95.2017.07.16.22.45.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 16 Jul 2017 22:45:27 -0700 (PDT)
Subject: Re: [PATCH 3/8] x86/xen: Redefine XEN_ELFNOTE_INIT_P2M using PUD_SIZE
 * PTRS_PER_PUD
References: <20170716225954.74185-1-kirill.shutemov@linux.intel.com>
 <20170716225954.74185-4-kirill.shutemov@linux.intel.com>
From: Juergen Gross <jgross@suse.com>
Message-ID: <de750662-faee-ce5b-526e-3f03ab87419d@suse.com>
Date: Mon, 17 Jul 2017 07:45:24 +0200
MIME-Version: 1.0
In-Reply-To: <20170716225954.74185-4-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 17/07/17 00:59, Kirill A. Shutemov wrote:
> XEN_ELFNOTE_INIT_P2M has to be 512GB for both 4- and 5-level paging.
> (PUD_SIZE * PTRS_PER_PUD) would do this.
> 
> Unfortunately, we cannot use P4D_SIZE, which would fit here. With
> current headers structure it cannot be used in assembly, if p4d
> level is folded.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Reviewed-by: Juergen Gross <jgross@suse.com>


Thanks,

Juergen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
