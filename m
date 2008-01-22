Date: Tue, 22 Jan 2008 12:22:57 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 1/1] x86: fix early cpu_to_node panic from
	nr_free_zone_pages
Message-ID: <20080122112257.GC26634@elte.hu>
References: <20080121230644.752379000@sgi.com> <20080121230647.038245000@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080121230647.038245000@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: travis@sgi.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* travis@sgi.com <travis@sgi.com> wrote:

> An early call to nr_free_zone_pages() calls numa_node_id() which
> needs to call early_cpu_to_node() since per_cpu(cpu_to_node_map)
> might not be setup yet.
> 
> I also had to export x86_cpu_to_node_map_early_ptr because of some
> calls from the network code to numa_node_id():
> 
> 	net/ipv4/netfilter/arp_tables.c:
> 	net/ipv4/netfilter/ip_tables.c:
> 	net/ipv4/netfilter/ip_tables.c:
> 
> Applies to both:
> 	
> 	2.6.24-rc8-mm1
> 	2.6.24-rc8-mm1 + latest (08/01/21) git-x86 patch

thanks, applied.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
