Date: Mon, 7 Jan 2008 11:07:54 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 00/19] VM pageout scalability improvements
In-Reply-To: <1199466372.5290.37.camel@localhost>
Message-ID: <Pine.LNX.4.64.0801071107440.23617@schroedinger.engr.sgi.com>
References: <20080102224144.885671949@redhat.com>  <1199379128.5295.21.camel@localhost>
  <20080103120000.1768f220@cuia.boston.redhat.com>  <1199380412.5295.29.camel@localhost>
  <20080103170035.105d22c8@cuia.boston.redhat.com>  <1199463934.5290.20.camel@localhost>
  <p73d4sh8s93.fsf@bingen.suse.de> <1199466372.5290.37.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Eric Whitney <eric.whitney@hp.com>, Nick Dokos <nicholas.dokos@hp.com>
List-ID: <linux-mm.kvack.org>

On Fri, 4 Jan 2008, Lee Schermerhorn wrote:

> We see this on both NUMA and non-NUMA. x86_64 and ia64.  The basic
> criteria to reproduce is to be able to run thousands [or low 10s of
> thousands] of tasks, continually increasing the number until the system
> just goes into reclaim.  Instead of swapping, the system seems to
> hang--unresponsive from the console, but with "soft lockup" messages
> spitting out every few seconds...

Ditto here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
