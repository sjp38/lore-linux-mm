Date: Mon, 10 Mar 2008 21:50:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 0/9] Page flags V3: Cleanup and reorg
Message-Id: <20080310215003.8622e6b8.akpm@linux-foundation.org>
In-Reply-To: <20080308001850.306617873@sgi.com>
References: <20080308001850.306617873@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: apw@shadowen.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 07 Mar 2008 16:18:50 -0800 Christoph Lameter <clameter@sgi.com> wrote:

> A set of patches that attempts to improve page flag handling.

First darn thing I tried was i386 allnoconfig and it goes splat.

In file included from include/linux/mm.h:192,
                 from kernel/bounds.c:8:
include/linux/page-flags.h: In function 'PageHighMem':
include/linux/page-flags.h:180: error: implicit declaration of function 'page_zone'

There's also a parenthesis mismatch so it looks like it was neither
compile-time nor runtime tested on i386.  Sorry, but I don't have the time
to be the first one to try this out.


To fix this page-flags.h needs to include mm.h, but mm.h includes
page-flags.h.  Making PageHighMem a macro would be the expedient fix.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
