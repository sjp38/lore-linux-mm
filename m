Date: Tue, 19 Feb 2002 09:30:46 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [RFC] Page table sharing
In-Reply-To: <m1heoe3xls.fsf@frodo.biederman.org>
Message-ID: <Pine.LNX.4.33.0202190929300.26476-100000@home.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Daniel Phillips <phillips@bonn-fries.net>, Hugh Dickins <hugh@veritas.com>, dmccr@us.ibm.com, Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Robert Love <rml@tech9.net>, Rik van Riel <riel@conectiva.com.br>, mingo@redhat.com, Andrew Morton <akpm@zip.com.au>, manfred@colorfullife.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>


On 18 Feb 2002, Eric W. Biederman wrote:
> > [1] I think that's a big, broad hint.
>
> Something like:
> struct mm_share {
>         spinlock_t page_table_lock;
>         struct list_head mm_list;
> };
>
> struct mm {
> 	struct list_head mm_list;
>         struct mm_share *mm_share;
>         .....
> };
>
> So we have an overarching structure for all of the shared mm's.

No, but the mm's aren't shared, only the pmd's are.

So one mm can share one pmd with mm2, and another with mm3.

Sure, you could have a list of "all mm's that _could_ share, and that
might work out well enough. An execve() removes a process from the list,
so usually the list is quite small.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
