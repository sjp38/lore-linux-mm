Date: Fri, 28 Mar 2008 11:51:09 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 4/9] Pageflags: Get rid of FLAGS_RESERVED
In-Reply-To: <20080328011240.fae44d52.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0803281148110.17920@schroedinger.engr.sgi.com>
References: <20080318181957.138598511@sgi.com> <20080318182035.197900850@sgi.com>
 <20080328011240.fae44d52.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: apw@shadowen.org, David Miller <davem@davemloft.net>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Jeremy Fitzhardinge <jeremy@goop.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 28 Mar 2008, Andrew Morton wrote:

> For some reason this isn't working on mips - include/linux/bounds.h has no
> #define for NR_PAGEFLAGS.

Likely an asm issue? Are there no definitions at all in 
include/linux/bounds.h?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
