Date: Thu, 20 Oct 2005 16:06:38 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 0/4] Swap migration V3: Overview
Message-Id: <20051020160638.58b4d08d.akpm@osdl.org>
In-Reply-To: <20051020225935.19761.57434.sendpatchset@schroedinger.engr.sgi.com>
References: <20051020225935.19761.57434.sendpatchset@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: kravetz@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, magnus.damm@gmail.com, marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@sgi.com> wrote:
>
> Page migration is also useful for other purposes:
> 
>  1. Memory hotplug. Migrating processes off a memory node that is going
>     to be disconnected.
> 
>  2. Remapping of bad pages. These could be detected through soft ECC errors
>     and other mechanisms.

It's only useful for these things if it works with close-to-100% reliability.

And there are are all sorts of things which will prevent that - mlock,
ongoing direct-io, hugepages, whatever.

So before we can commit ourselves to the initial parts of this path we'd
need some reassurance that the overall scheme addresses these things and
that the end result has a high probability of supporting hot unplug and
remapping sufficiently well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
