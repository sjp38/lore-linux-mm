Subject: Re: [patch 00/19] VM pageout scalability improvements
From: Andi Kleen <andi@firstfloor.org>
References: <20080102224144.885671949@redhat.com>
	<1199379128.5295.21.camel@localhost>
	<20080103120000.1768f220@cuia.boston.redhat.com>
	<1199380412.5295.29.camel@localhost>
	<20080103170035.105d22c8@cuia.boston.redhat.com>
	<1199463934.5290.20.camel@localhost>
Date: Fri, 04 Jan 2008 17:34:00 +0100
In-Reply-To: <1199463934.5290.20.camel@localhost> (Lee Schermerhorn's message of "Fri\, 04 Jan 2008 11\:25\:34 -0500")
Message-ID: <p73d4sh8s93.fsf@bingen.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Eric Whitney <eric.whitney@hp.com>, Nick Dokos <nicholas.dokos@hp.com>
List-ID: <linux-mm.kvack.org>

Lee Schermerhorn <Lee.Schermerhorn@hp.com> writes:

> We can easily [he says, glibly] reproduce the hang on the anon_vma lock

Is that a NUMA platform? On non x86? Perhaps you just need queued spinlocks?

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
