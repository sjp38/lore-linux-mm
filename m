Date: Fri, 28 Mar 2008 11:59:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 4/9] Pageflags: Get rid of FLAGS_RESERVED
Message-Id: <20080328115919.12c0445b.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0803281148110.17920@schroedinger.engr.sgi.com>
References: <20080318181957.138598511@sgi.com>
	<20080318182035.197900850@sgi.com>
	<20080328011240.fae44d52.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0803281148110.17920@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: apw@shadowen.org, davem@davemloft.net, kamezawa.hiroyu@jp.fujitsu.com, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, jeremy@goop.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 28 Mar 2008 11:51:09 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Fri, 28 Mar 2008, Andrew Morton wrote:
> 
> > For some reason this isn't working on mips - include/linux/bounds.h has no
> > #define for NR_PAGEFLAGS.
> 
> Likely an asm issue? Are there no definitions at all in 
> include/linux/bounds.h?

None - just the skeleton comments and ifdefs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
