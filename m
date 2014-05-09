Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f170.google.com (mail-ve0-f170.google.com [209.85.128.170])
	by kanga.kvack.org (Postfix) with ESMTP id DD27F6B0036
	for <linux-mm@kvack.org>; Fri,  9 May 2014 10:06:13 -0400 (EDT)
Received: by mail-ve0-f170.google.com with SMTP id db11so5260703veb.15
        for <linux-mm@kvack.org>; Fri, 09 May 2014 07:06:13 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id is5si2336020pbb.1.2014.05.09.07.06.12
        for <linux-mm@kvack.org>;
        Fri, 09 May 2014 07:06:13 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <CA+55aFw9eiaFtr+c4gcGSWG=pPeqDnX5aPQMVMqX1XkPF30ahg@mail.gmail.com>
References: <1399552888-11024-1-git-send-email-kirill.shutemov@linux.intel.com>
 <CAMSv6X0+3-uNeiyEPD3sA5dA6Af_M+BT0aeVpa3qMv1aga0q9g@mail.gmail.com>
 <20140508160205.A0EC7E009B@blue.fi.intel.com>
 <CA+55aFw9eiaFtr+c4gcGSWG=pPeqDnX5aPQMVMqX1XkPF30ahg@mail.gmail.com>
Subject: Re: [PATCHv2 0/2] remap_file_pages() decommission
Content-Transfer-Encoding: 7bit
Message-Id: <20140509140536.F06BFE009B@blue.fi.intel.com>
Date: Fri,  9 May 2014 17:05:36 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Armin Rigo <arigo@tunes.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>

Linus Torvalds wrote:
> On Thu, May 8, 2014 at 9:02 AM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
> >
> >> i.e. if you remove or
> >> emulate remap_file_pages(), please increase the default limit as well.
> >
> > It's fine to me. Andrew?
> 
> Not Andrew, but one thing we might look at is to make the limit
> per-user rather than per-vm.

Hm. I'm confused here. Do we have any limit forced per-user?
I only see things like rlimits which are copied from parrent.
Is it what you want?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
