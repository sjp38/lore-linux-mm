Received: by ug-out-1314.google.com with SMTP id m2so2710705ugc
        for <Linux-mm@kvack.org>; Mon, 12 Jun 2006 22:53:48 -0700 (PDT)
Message-ID: <787b0d920606122253o4f1a9e18x1ca49c3ce005696f@mail.gmail.com>
Date: Tue, 13 Jun 2006 01:53:48 -0400
From: "Albert Cahalan" <acahalan@gmail.com>
Subject: Re: [PATCH]: Adding a counter in vma to indicate the number of physical_pages_backing it
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, ak@suse.de, rohitseth@google.com, akpm@osdl.org, Linux-mm@kvack.org, arjan@infradead.org, jengelh@linux01.gwdg.de
List-ID: <linux-mm.kvack.org>

Quoting two different people:

> BTW, what is smaps used for (who uses it), anyway?
...
> smaps is only a debugging kludge anyways and it's
> not a good idea to we bloat core data structures for it.

I'd be using it in procps for the pmap command if it
were not so horribly nasty. I may eventually get around
to using it, but maybe it's just too gross to tolerate.
That mess should never have slipped into the kernel.
Just take a look at /proc/self/smaps some time. Wow.

A month or two ago I supplied a patch to replace smaps
with something sanely parsable. I was essentially told
that we already have this lovely smaps dungheap that I
should just use, but a couple people were eager to see
the patch go in.

Anyway, I need smaps stuff plus info about locked memory
and page sizes. Solaris provides this. People seem to
like it. I guess it's for performance tuning of app code or
maybe for scalibility predictions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
