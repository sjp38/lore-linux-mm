Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f171.google.com (mail-ve0-f171.google.com [209.85.128.171])
	by kanga.kvack.org (Postfix) with ESMTP id DF0116B00F4
	for <linux-mm@kvack.org>; Thu,  8 May 2014 11:35:21 -0400 (EDT)
Received: by mail-ve0-f171.google.com with SMTP id oz11so3490827veb.2
        for <linux-mm@kvack.org>; Thu, 08 May 2014 08:35:21 -0700 (PDT)
Received: from mail-ve0-x22d.google.com (mail-ve0-x22d.google.com [2607:f8b0:400c:c01::22d])
        by mx.google.com with ESMTPS id sj10si235101vcb.123.2014.05.08.08.35.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 08 May 2014 08:35:21 -0700 (PDT)
Received: by mail-ve0-f173.google.com with SMTP id pa12so3460001veb.4
        for <linux-mm@kvack.org>; Thu, 08 May 2014 08:35:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1399552888-11024-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1399552888-11024-1-git-send-email-kirill.shutemov@linux.intel.com>
Date: Thu, 8 May 2014 08:35:20 -0700
Message-ID: <CA+55aFyQyZM_qKFeThXA=PJzPReb8-VYoKpcrRHP+0UydqqaGw@mail.gmail.com>
Subject: Re: [PATCHv2 0/2] remap_file_pages() decommission
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>

On Thu, May 8, 2014 at 5:41 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
>
> The second patch replaces remap_file_pages(2) with and emulation. I didn't
> find any real code (apart LTP) to test it on. So I wrote simple test case.
> See commit message for numbers.

I'm certainly ok with this. It removes code even in the "no cleanup of
the core VM" case, and performance doesn't seem to be horrible.

That said, I *really* want to get at least some minimal testing on
something that actually uses it as more than just a test-program. I'm
sure somebody inside RH has to have a 32-bit Oracle setup for
performance testing. Guys?

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
