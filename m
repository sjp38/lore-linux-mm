Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id 994E96B0035
	for <linux-mm@kvack.org>; Fri,  9 May 2014 14:22:14 -0400 (EDT)
Received: by mail-ee0-f47.google.com with SMTP id c13so2933568eek.20
        for <linux-mm@kvack.org>; Fri, 09 May 2014 11:22:13 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.199])
        by mx.google.com with ESMTP id n7si4677244eeu.349.2014.05.09.11.22.12
        for <linux-mm@kvack.org>;
        Fri, 09 May 2014 11:22:13 -0700 (PDT)
Date: Fri, 9 May 2014 21:19:35 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 0/2] remap_file_pages() decommission
Message-ID: <20140509181935.GA24841@node.dhcp.inet.fi>
References: <1399552888-11024-1-git-send-email-kirill.shutemov@linux.intel.com>
 <CAMSv6X0+3-uNeiyEPD3sA5dA6Af_M+BT0aeVpa3qMv1aga0q9g@mail.gmail.com>
 <20140508160205.A0EC7E009B@blue.fi.intel.com>
 <CA+55aFw9eiaFtr+c4gcGSWG=pPeqDnX5aPQMVMqX1XkPF30ahg@mail.gmail.com>
 <20140509140536.F06BFE009B@blue.fi.intel.com>
 <CA+55aFz9Yo7OC03tKt2wsdd8cDi00yxvMwszrsOsx0ZVEh6zqQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFz9Yo7OC03tKt2wsdd8cDi00yxvMwszrsOsx0ZVEh6zqQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Armin Rigo <arigo@tunes.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>

On Fri, May 09, 2014 at 08:14:08AM -0700, Linus Torvalds wrote:
> On Fri, May 9, 2014 at 7:05 AM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
> >
> > Hm. I'm confused here. Do we have any limit forced per-user?
> 
> Sure we do. See "struct user_struct". We limit max number of
> processes, open files, signals etc.

Okay got it.

BTW, nobody seems use field 'files' of user_struct:
