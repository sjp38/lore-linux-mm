Return-Path: <owner-linux-mm@kvack.org>
Date: Thu, 19 Dec 2013 14:26:21 -0500
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: bad page state in 3.13-rc4
Message-ID: <20131219192621.GA9228@kvack.org>
References: <20131219040738.GA10316@redhat.com> <CA+55aFwweoGs3eGWXFULcqnbRbpDhpj2qrefXB5OpQOiWW8wYA@mail.gmail.com> <20131219155313.GA25771@redhat.com> <CA+55aFyoXCDNfHb+r5b=CgKQLPA1wrU_Tmh4ROZNEt5TPjpODA@mail.gmail.com> <20131219181134.GC25385@kmo-pixel> <20131219182920.GG30640@kvack.org> <CA+55aFzCo_r7ZGHk+zqUjmCW2w7-7z9oxEJjhR66tZ4qZPxnvw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzCo_r7ZGHk+zqUjmCW2w7-7z9oxEJjhR66tZ4qZPxnvw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kent Overstreet <kmo@daterainc.com>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@gentwo.org>, Al Viro <viro@zeniv.linux.org.uk>

On Fri, Dec 20, 2013 at 04:19:15AM +0900, Linus Torvalds wrote:
> Yeah, that looks horribly buggy, if that's the intent.
> 
> You can't just put_page() to remove something from the page cache. You
> need to do the whole "remove from radix tree" rigamarole, see for
> example delete_from_page_cache(). And you can't even do that blindly,
> because if the page is under writeback or otherwise busy, just
> removing it from the page cache and freeing it is wrong too.

Okay, I'll rewriting it to use truncate to free the pages.

		-ben

>                  Linus

-- 
"Thought is the essence of where you are now."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
