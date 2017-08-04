Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 443F06B059A
	for <linux-mm@kvack.org>; Fri,  4 Aug 2017 19:44:41 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v102so7611247wrb.2
        for <linux-mm@kvack.org>; Fri, 04 Aug 2017 16:44:41 -0700 (PDT)
Received: from mail-wm0-x22d.google.com (mail-wm0-x22d.google.com. [2a00:1450:400c:c09::22d])
        by mx.google.com with ESMTPS id v10si4513581edj.309.2017.08.04.16.44.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Aug 2017 16:44:39 -0700 (PDT)
Received: by mail-wm0-x22d.google.com with SMTP id t201so30472767wmt.0
        for <linux-mm@kvack.org>; Fri, 04 Aug 2017 16:44:39 -0700 (PDT)
Date: Sat, 5 Aug 2017 02:44:35 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 0/2] mm,fork,security: introduce MADV_WIPEONFORK
Message-ID: <20170804234435.lkblljl3f3ud2spm@node.shutemov.name>
References: <20170804190730.17858-1-riel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170804190730.17858-1-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, fweimer@redhat.com, colm@allcosts.net, akpm@linux-foundation.org, rppt@linux.vnet.ibm.com, keescook@chromium.org, luto@amacapital.net, wad@chromium.org, mingo@kernel.org

On Fri, Aug 04, 2017 at 03:07:28PM -0400, riel@redhat.com wrote:
> [resend because half the recipients got dropped due to IPv6 firewall issues]
> 
> Introduce MADV_WIPEONFORK semantics, which result in a VMA being
> empty in the child process after fork. This differs from MADV_DONTFORK
> in one important way.
> 
> If a child process accesses memory that was MADV_WIPEONFORK, it
> will get zeroes. The address ranges are still valid, they are just empty.

I feel like we are repeating mistake we made with MADV_DONTNEED.

MADV_WIPEONFORK would require a specific action from kernel, ignoring
the /advise/ would likely lead to application misbehaviour.

Is it something we really want to see from madvise()?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
