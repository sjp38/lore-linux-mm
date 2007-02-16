From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC] Remove unswappable anonymous pages off the LRU
Date: Fri, 16 Feb 2007 10:11:39 +0100
References: <Pine.LNX.4.64.0702151300500.31366@schroedinger.engr.sgi.com> <20070215184800.e2820947.akpm@linux-foundation.org> <1171613727.24923.54.camel@twins>
In-Reply-To: <1171613727.24923.54.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200702161011.40640.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Martin Bligh <mbligh@mbligh.org>, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Friday, 16 February 2007 09:15, Peter Zijlstra wrote:
> On Thu, 2007-02-15 at 18:48 -0800, Andrew Morton wrote:
> 
> > The two swsusp bits can be removed: they're only needed at suspend/resume
> > time and can be replaced by an external data structure.
> 
> I once had a talk with Rafael, and he said it would be possible to rid
> us of PG_nosave* with the now not so new bitmap code that is used to
> handle swsusp of highmem pages.

Yes, that is true.

I'm going to do this soon, but first I'd like to help to make the task freezer
suitable for the CPU hotplug.

Greetings,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
