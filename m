Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f174.google.com (mail-ve0-f174.google.com [209.85.128.174])
	by kanga.kvack.org (Postfix) with ESMTP id 5D4016B0035
	for <linux-mm@kvack.org>; Fri,  9 May 2014 11:14:09 -0400 (EDT)
Received: by mail-ve0-f174.google.com with SMTP id jw12so5393210veb.33
        for <linux-mm@kvack.org>; Fri, 09 May 2014 08:14:09 -0700 (PDT)
Received: from mail-ve0-x231.google.com (mail-ve0-x231.google.com [2607:f8b0:400c:c01::231])
        by mx.google.com with ESMTPS id dr8si772135vcb.121.2014.05.09.08.14.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 09 May 2014 08:14:08 -0700 (PDT)
Received: by mail-ve0-f177.google.com with SMTP id db11so5336994veb.36
        for <linux-mm@kvack.org>; Fri, 09 May 2014 08:14:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140509140536.F06BFE009B@blue.fi.intel.com>
References: <1399552888-11024-1-git-send-email-kirill.shutemov@linux.intel.com>
	<CAMSv6X0+3-uNeiyEPD3sA5dA6Af_M+BT0aeVpa3qMv1aga0q9g@mail.gmail.com>
	<20140508160205.A0EC7E009B@blue.fi.intel.com>
	<CA+55aFw9eiaFtr+c4gcGSWG=pPeqDnX5aPQMVMqX1XkPF30ahg@mail.gmail.com>
	<20140509140536.F06BFE009B@blue.fi.intel.com>
Date: Fri, 9 May 2014 08:14:08 -0700
Message-ID: <CA+55aFz9Yo7OC03tKt2wsdd8cDi00yxvMwszrsOsx0ZVEh6zqQ@mail.gmail.com>
Subject: Re: [PATCHv2 0/2] remap_file_pages() decommission
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Armin Rigo <arigo@tunes.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>

On Fri, May 9, 2014 at 7:05 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
>
> Hm. I'm confused here. Do we have any limit forced per-user?

Sure we do. See "struct user_struct". We limit max number of
processes, open files, signals etc.

> I only see things like rlimits which are copied from parrent.
> Is it what you want?

No, rlimits are per process (although in some cases what they limit
are counted per user despite the _limits_ of those resources then
being settable per thread).

So I was just thinking that if we raise the per-mm default limits,
maybe we should add a global per-user limit to make it harder for a
user to use tons and toms of vma's.

          Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
