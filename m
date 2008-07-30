Date: Wed, 30 Jul 2008 18:46:21 -0400
From: Rik van Riel <riel@surriel.com>
Subject: Re: [PATCH 6/7] mlocked-pages:  patch reject resolution and event
 renames
Message-ID: <20080730184621.051ce090@bree.surriel.com>
In-Reply-To: <20080730133004.9c0dacbd.akpm@linux-foundation.org>
References: <20080730200618.24272.31756.sendpatchset@lts-notebook>
	<20080730200655.24272.39854.sendpatchset@lts-notebook>
	<20080730133004.9c0dacbd.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, Eric.Whitney@hp.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Wed, 30 Jul 2008 13:30:04 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> I have a feeling that I merged all these patches too soon - the amount
> of rework has been tremendous.  Are we done yet?

I can't speak for the unreclaimable part of the patch series,
but the first half of the split LRU series should be in a good
shape now that you merged the patch from Johannes Weiner.

I am not aware of a situation where the split LRU VM performs
worse than what is currently upstream, but I will continue to
try finding performance regressions to fix :)

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
