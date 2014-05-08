Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f180.google.com (mail-vc0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id 375216B00FE
	for <linux-mm@kvack.org>; Thu,  8 May 2014 12:08:28 -0400 (EDT)
Received: by mail-vc0-f180.google.com with SMTP id hy4so2713250vcb.25
        for <linux-mm@kvack.org>; Thu, 08 May 2014 09:08:28 -0700 (PDT)
Received: from mail-ve0-x229.google.com (mail-ve0-x229.google.com [2607:f8b0:400c:c01::229])
        by mx.google.com with ESMTPS id ui2si248107vdc.154.2014.05.08.09.08.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 08 May 2014 09:08:27 -0700 (PDT)
Received: by mail-ve0-f169.google.com with SMTP id jx11so3623961veb.0
        for <linux-mm@kvack.org>; Thu, 08 May 2014 09:08:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140508160205.A0EC7E009B@blue.fi.intel.com>
References: <1399552888-11024-1-git-send-email-kirill.shutemov@linux.intel.com>
	<CAMSv6X0+3-uNeiyEPD3sA5dA6Af_M+BT0aeVpa3qMv1aga0q9g@mail.gmail.com>
	<20140508160205.A0EC7E009B@blue.fi.intel.com>
Date: Thu, 8 May 2014 09:08:27 -0700
Message-ID: <CA+55aFw9eiaFtr+c4gcGSWG=pPeqDnX5aPQMVMqX1XkPF30ahg@mail.gmail.com>
Subject: Re: [PATCHv2 0/2] remap_file_pages() decommission
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Armin Rigo <arigo@tunes.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>

On Thu, May 8, 2014 at 9:02 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
>
>> i.e. if you remove or
>> emulate remap_file_pages(), please increase the default limit as well.
>
> It's fine to me. Andrew?

Not Andrew, but one thing we might look at is to make the limit
per-user rather than per-vm.

Because the vma limit isn't _just_ about the ELF core dump format
(although the default value for it is), it's also about making it
harder for people to use up tons of kernel memory in non-obvious ways.

(There are possibly also latency issues for process exit or big
munmap, I'm not sure how big a deal that is any more. Our find_vma()
should certainly scale fine, so the most obvious "tons of vma's"
problems are long gone)

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
