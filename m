Date: Thu, 22 Apr 2004 03:50:54 -0400 (EDT)
From: Ingo Molnar <mingo@redhat.com>
Subject: Re: Non-linear mappings and truncate/madvise(MADV_DONTNEED)
In-Reply-To: <Pine.LNX.4.44.0404191548030.24243-100000@localhost.localdomain>
Message-ID: <Pine.LNX.4.58.0404220349040.13746@devserv.devel.redhat.com>
References: <Pine.LNX.4.44.0404191548030.24243-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Jamie Lokier <jamie@shareable.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 19 Apr 2004, Hugh Dickins wrote:

> rmap 6 nonlinear truncation (which never appeared on LKML, though
> sent twice) fixed most of this, and went into 2.6.6-rc1-bk4 last
> night: please check it out.
> 
> But I just converted madvise_dontneed by rote, adding a NULL arg to
> zap_page_range, missing your point that it should respect nonlinearity.
> 
> And I made the zap_details structure private to mm/memory.c since I
> hadn't noticed anything outside needing it: I'll fix that up later and
> post a patch.
> 
> I'm haven't and don't intend to change the behaviour of ->populate,
> without agreement from others - Ingo? Jamie?

feel free. I've got followup work, protection bits stored in the swap pte,
thus per-page protection possible via remap_file_pages_prot(). (earlier
-mm trees had this but it clashed with objrmap which has priority.)

	Ingo
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
