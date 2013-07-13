Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 0BAB56B0031
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 23:08:56 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so21999640ied.14
        for <linux-mm@kvack.org>; Fri, 12 Jul 2013 20:08:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130712074558.GP18798@sgi.com>
References: <1373594635-131067-1-git-send-email-holt@sgi.com>
	<1373594635-131067-3-git-send-email-holt@sgi.com>
	<20130712074558.GP18798@sgi.com>
Date: Fri, 12 Jul 2013 20:08:56 -0700
Message-ID: <CAE9FiQVYApvncM0gKZYoJ9LE0636rhCD70qGJe0ksxeXQ68jWw@mail.gmail.com>
Subject: Re: [RFC 2/4] Have __free_pages_memory() free in larger chunks.
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Nate Zimmer <nzimmer@sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Rob Landley <rob@landley.net>, Mike Travis <travis@sgi.com>, Daniel J Blueman <daniel@numascale-asia.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Mel Gorman <mgorman@suse.de>

On Fri, Jul 12, 2013 at 12:45 AM, Robin Holt <holt@sgi.com> wrote:

> At the very least, I think we could change to:
> static void __init __free_pages_memory(unsigned long start, unsigned long end)
> {
>         int order;
>
>         while (start < end) {
>                 order = ffs(start);
>
>                 while (start + (1UL << order) > end)
>                         order--;
>
>                 __free_pages_bootmem(start, order);
>
>                 start += (1UL << order);
>         }
> }

should work, but need to make sure order < MAX_ORDER.

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
