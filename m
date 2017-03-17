Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E99656B038B
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 15:49:54 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id g8so5170218wmg.7
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 12:49:54 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id x7si3736207wmf.30.2017.03.17.12.49.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 17 Mar 2017 12:49:53 -0700 (PDT)
Date: Fri, 17 Mar 2017 20:49:35 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 3/6] x86/mm/pat: Add 5-level paging support
In-Reply-To: <20170317185515.8636-4-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.DEB.2.20.1703172049100.3790@nanos>
References: <20170317185515.8636-1-kirill.shutemov@linux.intel.com> <20170317185515.8636-4-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 17 Mar 2017, Kirill A. Shutemov wrote:

> Straight-forward extension of existing code to support additional page
> table level.

Nicely done!

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
