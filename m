Subject: Re: [PATCH] Update Unevictable LRU and Mlocked Pages documentation
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <48931AD1.6040904@linux-foundation.org>
References: <1217452439.7676.26.camel@lts-notebook>
	 <4891C8BC.1020509@linux-foundation.org>
	 <1217515429.6507.7.camel@lts-notebook>
	 <489313AC.3080605@linux-foundation.org>
	 <20080801100623.4aae3e37@bree.surriel.com>
	 <48931AD1.6040904@linux-foundation.org>
Content-Type: text/plain
Date: Fri, 01 Aug 2008 10:36:08 -0400
Message-Id: <1217601369.6232.16.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Fri, 2008-08-01 at 09:16 -0500, Christoph Lameter wrote:
> Rik van Riel wrote:
> > On Fri, 01 Aug 2008 08:46:20 -0500
> > Christoph Lameter <cl@linux-foundation.org> wrote:
> > 
> >> Yes I know and I think the rationale is not convincing if the justification
> >> of the additional LRU is primarily for page migration.
> > 
> > Basically there are two alternatives:
> 
> I think we have sufficient reasons to have a second LRU (see my earlier mail)
> just the text did not emphasize the right ones.

Really?  You think it would be OK to leave maybe gigabytes of mlocked
pages non-migratable?  This would prevent defrag, hotplug, and cpuset
movement.  Since you went to the effort to make mlocked pages migratable
in the first place, I thought we ought to preserve this capability.
This was MY primary reason for keeping them on an LRU-like list that
isolate_lru_page and the new putback_lru_page() know about.  Otherwise,
we could just let them float, unmanaged, as Nick's original patch did.
I wanted to capture this in the doc so that down the road, folks will at
least think about this implication when considering leaving pages
unmanaged by any "lru list".

The rationale that Rik mentioned--common handling, as much as
possible--was the second reason mentioned in the text.  Perhaps my
wording could use some rework/clarification.

Lee



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
