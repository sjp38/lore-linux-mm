Date: Fri, 4 Jan 2008 11:55:24 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [patch 00/19] VM pageout scalability improvements
Message-ID: <20080104115524.7d906f94@bree.surriel.com>
In-Reply-To: <p73d4sh8s93.fsf@bingen.suse.de>
References: <20080102224144.885671949@redhat.com>
	<1199379128.5295.21.camel@localhost>
	<20080103120000.1768f220@cuia.boston.redhat.com>
	<1199380412.5295.29.camel@localhost>
	<20080103170035.105d22c8@cuia.boston.redhat.com>
	<1199463934.5290.20.camel@localhost>
	<p73d4sh8s93.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Eric Whitney <eric.whitney@hp.com>, Nick Dokos <nicholas.dokos@hp.com>
List-ID: <linux-mm.kvack.org>

On Fri, 04 Jan 2008 17:34:00 +0100
Andi Kleen <andi@firstfloor.org> wrote:
> Lee Schermerhorn <Lee.Schermerhorn@hp.com> writes:
> 
> > We can easily [he says, glibly] reproduce the hang on the anon_vma lock
> 
> Is that a NUMA platform? On non x86? Perhaps you just need queued spinlocks?

I really think that the anon_vma and i_mmap_lock spinlock hangs are
due to the lack of queued spinlocks.  Not because I have seen your
system hang, but because I've seen one of Larry's test systems here
hang in scary/amusing ways :)

With queued spinlocks the system should just slow down, not hang.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
