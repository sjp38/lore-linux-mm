Date: Mon, 24 Nov 2008 19:38:34 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH][V2] Make get_user_pages interruptible
In-Reply-To: <Pine.LNX.4.64.0811241859160.3700@blonde.site>
Message-ID: <Pine.LNX.4.64.0811241933130.9595@blonde.site>
References: <604427e00811211605j20fd00bby1bac86b4cc3c380b@mail.gmail.com>
 <alpine.DEB.2.00.0811211618160.20523@chino.kir.corp.google.com>
 <6599ad830811211818g5ade68cua396713be94f80dc@mail.gmail.com>
 <alpine.DEB.2.00.0811220152300.18236@chino.kir.corp.google.com>
 <604427e00811240938n5eca39cetb37b4a63f20a0854@mail.gmail.com>
 <Pine.LNX.4.64.0811241859160.3700@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Cc: Ying Han <yinghan@google.com>, David Rientjes <rientjes@google.com>, Paul Menage <menage@google.com>, linux-mm@kvack.org, akpm <akpm@linux-foundation.org>, Rohit Seth <rohitseth@google.com>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Ben,

On Mon, 24 Nov 2008, Hugh Dickins wrote:
> On Mon, 24 Nov 2008, Ying Han wrote:
> > --Ying
> > 
> > On Sat, Nov 22, 2008 at 12:07 PM, David Rientjes <rientjes@google.com> wrote:
> > > On Fri, 21 Nov 2008, Paul Menage wrote:
> > >
> > >> No, I didn't exactly write it originally - the only thing I added in
> > >> our kernel was the use of sigkill_pending() rather than checking for
> > >> TIF_MEMDIE.
> > >>
> > >
> > > That's what this patch does, its title just appears to be wrong since it
> > > was already interruptible.
> > >
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> The linux-mm list has a tiresome habit of removing one line at the top.
> 
> For a year or so I used to wonder why Christoph Lameter sent so many
> empty messages in response to patches: at last I realized he was
> sending a single-line Acked-by: which linux-mm kindly removed.
> 
> I grow tired of it, but forget who to report it to: Rik is sure to know.
> 
> Ah, looking at the raw mailbox, I see
> 
> ...
> X-Loop:	owner-majordomo@kvack.org
> David:	I made the two fixes and posted another thread as [PATCH][V3]
> X-OriginalArrivalTime: 24 Nov 2008 17:39:37.0205 (UTC) FILETIME=[9EEC5A50:01C94E5B]
> ...
> 
> so it looks as if a first line with a colon gets treated as header.
> 
> Of course, in your case, it serves you right for top-posting ;)

Thanks to Andrew for reminding me that you're the man for linux-mm:
see from the above, I have a gripe - please, something you could fix?

Thanks a lot,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
