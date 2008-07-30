Date: Wed, 30 Jul 2008 13:30:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 6/7] mlocked-pages:  patch reject resolution and event
 renames
Message-Id: <20080730133004.9c0dacbd.akpm@linux-foundation.org>
In-Reply-To: <20080730200655.24272.39854.sendpatchset@lts-notebook>
References: <20080730200618.24272.31756.sendpatchset@lts-notebook>
	<20080730200655.24272.39854.sendpatchset@lts-notebook>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, riel@surriel.com, Eric.Whitney@hp.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Wed, 30 Jul 2008 16:06:55 -0400
Lee Schermerhorn <lee.schermerhorn@hp.com> wrote:

> Reworked to resolve patch conflicts introduced by other patches,
> including rename of unevictable lru/mlocked pages events.

I hope I was supposed to drop
vmstat-unevictable-and-mlocked-pages-vm-events.patch - it was getting
100% rejects.  After dropping it, everything applied.  Dunno if it
compiles yet.

I have a feeling that I merged all these patches too soon - the amount
of rework has been tremendous.  Are we done yet?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
