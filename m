Date: Fri, 28 Mar 2008 01:12:40 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 4/9] Pageflags: Get rid of FLAGS_RESERVED
Message-Id: <20080328011240.fae44d52.akpm@linux-foundation.org>
In-Reply-To: <20080318182035.197900850@sgi.com>
References: <20080318181957.138598511@sgi.com>
	<20080318182035.197900850@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: apw@shadowen.org, David Miller <davem@davemloft.net>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Jeremy Fitzhardinge <jeremy@goop.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 18 Mar 2008 11:20:01 -0700 Christoph Lameter <clameter@sgi.com> wrote:

> NR_PAGEFLAGS specifies the number of page flags we are using.
> >From that we can calculate the number of bits leftover that can
> be used for zone, node (and maybe the sections id). There is
> no need anymore for FLAGS_RESERVED if we use NR_PAGEFLAGS.
> 
> Use the new methods to make NR_PAGEFLAGS available via
> the preprocessor. NR_PAGEFLAGS is used to calculate field
> boundaries in the page flags fields. These field widths have

For some reason this isn't working on mips - include/linux/bounds.h has no
#define for NR_PAGEFLAGS.

http://userweb.kernel.org/~akpm/cross-compilers/ has the i386->mips
toolchain which I'm using.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
