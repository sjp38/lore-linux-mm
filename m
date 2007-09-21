Date: Fri, 21 Sep 2007 15:46:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/1] x86: Convert cpuinfo_x86 array to a per_cpu array
 v2
Message-Id: <20070921154622.c6920dcf.akpm@linux-foundation.org>
In-Reply-To: <20070920213004.781159000@sgi.com>
References: <20070920213004.527735000@sgi.com>
	<20070920213004.781159000@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: travis@sgi.com
Cc: Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 20 Sep 2007 14:30:05 -0700
travis@sgi.com wrote:

> cpu_data is currently an array defined using NR_CPUS. This means that
> we overallocate since we will rarely really use maximum configured cpus.
> When NR_CPU count is raised to 4096 the size of cpu_data becomes
> 3,145,728 bytes.

This has at least three quite obvious and careless compilation errors.

Please at least compile the code after you've altered it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
