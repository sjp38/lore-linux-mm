Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id F07E96B0032
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 18:56:29 -0400 (EDT)
Received: by iecrt8 with SMTP id rt8so30425637iec.0
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 15:56:29 -0700 (PDT)
Received: from mail-ie0-x22e.google.com (mail-ie0-x22e.google.com. [2607:f8b0:4001:c03::22e])
        by mx.google.com with ESMTPS id f19si19971336icl.8.2015.04.28.15.56.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Apr 2015 15:56:29 -0700 (PDT)
Received: by iebrs15 with SMTP id rs15so30408775ieb.3
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 15:56:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150428221553.GA5770@node.dhcp.inet.fi>
References: <20150428221553.GA5770@node.dhcp.inet.fi>
Date: Tue, 28 Apr 2015 15:56:29 -0700
Message-ID: <CA+55aFyG8dsL_dwZ=t+4ZwcUGjo1rq6gZteuwFdPmpUe6niX5w@mail.gmail.com>
Subject: Re: PCID and TLB flushes (was: [GIT PULL] kdbus for 4.1-rc1)
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andy Lutomirski <luto@amacapital.net>, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>

On Tue, Apr 28, 2015 at 3:15 PM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
>
> I talked with Dave about implementing PCID and he thinks that it will be
> net loss.

So I'm told that Suresh Siddha actually had a patch inside Intel to
use PCID (back when he worked for Intel, I think he left), and that it
was a wash in their testing.

I never saw the patch, and it might be interesting to try it again,
but there is some reason to believe that it doesn't make much of a
difference. Unlike most of the traditional RISC machines that got big
speedups, Intel TLB walking is so good that it likely isn't nearly as
noticeable, and it likely *does* result in more IPI's etc. Possibly
not a lot more, but if the win isn't big...

So I don't want to discourage you, because I'd love to see what the
patch looks like and if we can find cases where it matters, but I do
want to set expectations right. It's unlikely to be a big issue.

                           Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
