Date: Fri, 30 Jun 2006 16:38:49 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: ZVC/zone_reclaim: Leave 1% of unmapped pagecache pages for file
 I/O
Message-Id: <20060630163849.6365b7a9.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0606301407460.8022@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0606291949320.30754@schroedinger.engr.sgi.com>
	<200606301219.19473.ak@suse.de>
	<Pine.LNX.4.64.0606301407460.8022@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: ak@suse.de, schamp@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@sgi.com> wrote:
>
> +min_unmapped:
> +
> +A percentage of the file backed pages in each zone. Zone reclaim will only
> +occur if more than this percentage of pages are file backed and unmapped.
> +This is to insure that a minimal amount of local pages is still available
> +for file I/O even if the node is overallocated.
> +
> +The default is 1 percent.
> +

Probably this should have a big "NUMA only" slapped on it so people don't
wonder why they don't have such a file.

Also, it's nice if the naming of these control files can communicate the
units to the operator.  In the case of /proc/sys/vm we use _ratio to
indicate that it's a proportional control in the 0% - 100% range.

So /proc/sys/vm/min_unmapped_ratio would be clearer, and more consistent.

<looks forward to the day when this becomes per-node :(>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
