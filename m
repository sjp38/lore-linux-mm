Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f50.google.com (mail-qa0-f50.google.com [209.85.216.50])
	by kanga.kvack.org (Postfix) with ESMTP id 8B3CD6B0035
	for <linux-mm@kvack.org>; Mon, 12 May 2014 03:51:01 -0400 (EDT)
Received: by mail-qa0-f50.google.com with SMTP id j15so6610522qaq.23
        for <linux-mm@kvack.org>; Mon, 12 May 2014 00:51:01 -0700 (PDT)
Received: from mail-qa0-x22a.google.com (mail-qa0-x22a.google.com [2607:f8b0:400d:c00::22a])
        by mx.google.com with ESMTPS id c4si5567394qad.256.2014.05.12.00.51.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 May 2014 00:51:00 -0700 (PDT)
Received: by mail-qa0-f42.google.com with SMTP id j5so6787006qaq.29
        for <linux-mm@kvack.org>; Mon, 12 May 2014 00:51:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <87tx8v4qin.fsf@tassilo.jf.intel.com>
References: <1399552888-11024-1-git-send-email-kirill.shutemov@linux.intel.com>
 <CAMSv6X0+3-uNeiyEPD3sA5dA6Af_M+BT0aeVpa3qMv1aga0q9g@mail.gmail.com> <87tx8v4qin.fsf@tassilo.jf.intel.com>
From: Armin Rigo <arigo@tunes.org>
Date: Mon, 12 May 2014 09:50:20 +0200
Message-ID: <CAMSv6X1_BzDE1ytPtdGQKK=OJJVpsPrwp2dgSZxA=A03n4rWJw@mail.gmail.com>
Subject: Re: [PATCHv2 0/2] remap_file_pages() decommission
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, mingo@kernel.org

Hi Andi,

On 12 May 2014 05:36, Andi Kleen <andi@firstfloor.org> wrote:
>> Here is a note from the PyPy project (mentioned earlier in this
>> thread, and at https://lwn.net/Articles/587923/ ).
>
> Your use is completely bogus. remap_file_pages() pins everything
> and disables any swapping for the area.

? No.  Trying this example: http://bpaste.net/show/fCUTnR9mDzJ2IEKrQLAR/

...really allocates 4GB of RAM, and on a 4GB machine it causes some
swapping.  It seems to work fine.  I'm not sure to understand you.
I'm also not sure that a property as essential as "disables swapping"
should be omitted from the man page; if so, that would be a real man
page bug.


A bient=C3=B4t,

Armin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
