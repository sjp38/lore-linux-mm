Date: Tue, 19 Feb 2002 02:56:21 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] reduce struct_page size
Message-ID: <20020219105621.GI3511@holomorphy.com>
References: <Pine.LNX.4.33.0202181806340.24597-100000@home.transmeta.com> <Pine.LNX.4.33L.0202190736290.1930-100000@imladris.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.33L.0202190736290.1930-100000@imladris.surriel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 18 Feb 2002, Rik van Riel wrote:
>>> o page->zone is shrunk from a pointer to an index into a small
>>>   array of zones ... this means we have space for 3 more chars
>>>   in the struct page to other stuff (say, page->age)

On Mon, 18 Feb 2002, Linus Torvalds wrote:
>> Why not put "page->zone" into the page flags instead?

On Tue, Feb 19, 2002 at 07:38:02AM -0300, Rik van Riel wrote:
> The original reason it's not in page->flags is that the
> rmap patch also has page->age.
> Furthermore, the NUMA folks wanted the ability to have
> quite a few zones.

I didn't have any particular objection to it. With ->age in there
the unsigned char didn't make a difference and it perhaps looked
cleaner.

On Mon, 18 Feb 2002, Linus Torvalds wrote:
>> The patch looks good, it's just silly to say that you made "struct page"
>> smaller, and then waste four bytes.

On Tue, Feb 19, 2002 at 07:38:02AM -0300, Rik van Riel wrote:
> If you want I'll look into shoving the zone bits into
> page->flags ...

I still have my old code sitting around that I could quickly
resurrect to provide this. I can integrate it and send it to
you for review if that would help.

I don't really care one way or the other about whether my original
implementation is reused so much as preventing my inaction from
delaying the merge. The difference is just trivial.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
