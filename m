Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8C1936B070F
	for <linux-mm@kvack.org>; Sat,  5 Aug 2017 11:21:48 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id i143so22564034qke.14
        for <linux-mm@kvack.org>; Sat, 05 Aug 2017 08:21:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a24si3462550qth.271.2017.08.05.08.21.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Aug 2017 08:21:47 -0700 (PDT)
Message-ID: <1501946504.6577.9.camel@redhat.com>
Subject: Re: [PATCH 0/2] mm,fork,security: introduce MADV_WIPEONFORK
From: Rik van Riel <riel@redhat.com>
Date: Sat, 05 Aug 2017 11:21:44 -0400
In-Reply-To: <20170804234435.lkblljl3f3ud2spm@node.shutemov.name>
References: <20170804190730.17858-1-riel@redhat.com>
	 <20170804234435.lkblljl3f3ud2spm@node.shutemov.name>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, fweimer@redhat.com, colm@allcosts.net, akpm@linux-foundation.org, rppt@linux.vnet.ibm.com, keescook@chromium.org, luto@amacapital.net, wad@chromium.org, mingo@kernel.org

On Sat, 2017-08-05 at 02:44 +0300, Kirill A. Shutemov wrote:
> On Fri, Aug 04, 2017 at 03:07:28PM -0400, riel@redhat.com wrote:
> > [resend because half the recipients got dropped due to IPv6
> > firewall issues]
> > 
> > Introduce MADV_WIPEONFORK semantics, which result in a VMA being
> > empty in the child process after fork. This differs from
> > MADV_DONTFORK
> > in one important way.
> > 
> > If a child process accesses memory that was MADV_WIPEONFORK, it
> > will get zeroes. The address ranges are still valid, they are just
> > empty.
> 
> I feel like we are repeating mistake we made with MADV_DONTNEED.
> 
> MADV_WIPEONFORK would require a specific action from kernel, ignoring
> the /advise/ would likely lead to application misbehaviour.
> 
> Is it something we really want to see from madvise()?

We already have various mandatory madvise behaviors in Linux,
including MADV_REMOVE, MADV_DONTFORK, and MADV_DONTDUMP.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
