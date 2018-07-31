Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id C315A6B000E
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 13:43:52 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id g24-v6so11775172plq.2
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 10:43:52 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id w11-v6si12933906plz.333.2018.07.31.10.43.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jul 2018 10:43:51 -0700 (PDT)
Date: Tue, 31 Jul 2018 10:43:50 -0700
From: "Luck, Tony" <tony.luck@intel.com>
Subject: Re: Linux 4.18-rc7
Message-ID: <20180731174349.GA12944@agluck-desk>
References: <CAMi1Hd0fJuAgP09_KkbjyGwszOXmxcPybKyBxP3U1y5JUqxxSw@mail.gmail.com>
 <20180730130134.yvn5tcmoavuxtwt5@kshutemo-mobl1>
 <CA+55aFwxwCPZs=h5wy-5PELwfBVuTETm+wuZB5cM2SDoXJi68g@mail.gmail.com>
 <alpine.LSU.2.11.1807301410470.4805@eggly.anvils>
 <CA+55aFx3qR1FW0T3na25NrwLZAvpOdUEUJa879CnaJT2ZPfhkg@mail.gmail.com>
 <alpine.LSU.2.11.1807301940460.5904@eggly.anvils>
 <CALAqxLU3cmu4g+HaB6A7=VhY-hW=d9e68EZ=_4JiwX_BigzjPQ@mail.gmail.com>
 <CAMi1Hd0-2eDod4HiBifKCxY0cUUEW_A-yv7sZ7GRgL0whWQt+w@mail.gmail.com>
 <CA+55aFx=-tHXjv3gv4W=xYwM+VOHJQE5q5VyihkPK7s560x-vQ@mail.gmail.com>
 <20180731170328.ocb5oikwhwtkyzrj@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180731170328.ocb5oikwhwtkyzrj@kshutemo-mobl1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Amit Pundir <amit.pundir@linaro.org>, John Stultz <john.stultz@linaro.org>, Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, youling 257 <youling257@gmail.com>, Joel Fernandes <joelaf@google.com>, Colin Cross <ccross@google.com>

On Tue, Jul 31, 2018 at 08:03:28PM +0300, Kirill A. Shutemov wrote:
> But it's not the only issue unfortunately. Tony reported issue with
> booting ia64 with the patch. I have no clue why. I rechecked everything
> ia64-specific and looks fine to me. :-/

If I just revert bfd40eaff5ab ("mm: fix vma_is_anonymous() false-positives")
then ia64 boots again.

-Tony
