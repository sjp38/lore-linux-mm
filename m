Date: Thu, 8 Jun 2006 21:00:56 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 04/14] Use per zone counters to remove
 zone_reclaim_interval
Message-Id: <20060608210056.9b2f3f13.akpm@osdl.org>
In-Reply-To: <20060608230305.25121.97821.sendpatchset@schroedinger.engr.sgi.com>
References: <20060608230239.25121.83503.sendpatchset@schroedinger.engr.sgi.com>
	<20060608230305.25121.97821.sendpatchset@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, hugh@veritas.com, nickpiggin@yahoo.com.au, linux-mm@kvack.org, ak@suse.de, marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

On Thu, 8 Jun 2006 16:03:05 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> Caveat: The number of mapped pages includes anonymous pages.
> The current check works but is a bit too cautious. We could perform
> zone reclaim down to the last unmapped page if we would split NR_MAPPED
> into NR_MAPPED_PAGECACHE and NR_MAPPED_ANON. Maybe later.

That caveat should be in a code comment, please.  Otherwise we'll forget.

You have two [patch 04/14]s and no [patch 05/14].

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
