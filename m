Date: Thu, 3 Apr 2003 01:06:16 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 2.5.66-mm2] Fix page_convert_anon locking issues
In-Reply-To: <102170000.1049325787@baldur.austin.ibm.com>
Message-ID: <Pine.LNX.4.44.0304030101430.1279-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2 Apr 2003, Dave McCracken wrote:
> --On Wednesday, April 02, 2003 15:09:03 -0800 Andrew Morton
> <akpm@digeo.com> wrote:
> > 
> > How about setting PageAnon at the _start_ of the operation? 
> > page_remove_rmap() will cope with that OK.
> 
> Hmm... I was gonna say that page_remove_rmap will BUG() if it doesn't find
> the entry, but it's only under DEBUG and could easily be changed.  Lemme
> think on this one a bit.  I need to assure myself it's safe to go unlocked
> in the middle.

Yes, it's an interesting idea, but by no means clear it's safe.
I'll think about it too, but sorry, no more tonight.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
