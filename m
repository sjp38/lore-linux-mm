Date: Fri, 14 Sep 2007 16:32:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 00/10] x86: Reduce Memory Usage and Inter-Node message
 traffic (v3)
Message-Id: <20070914163223.20759e54.akpm@linux-foundation.org>
In-Reply-To: <20070912015644.927677070@sgi.com>
References: <20070912015644.927677070@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: travis@sgi.com
Cc: Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, sparclinux@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 11 Sep 2007 18:56:44 -0700
travis@sgi.com wrote:

> Changes for version v3:
> 
> cpu_sibling_map has been converted to a per_cpu data array to fix
> build errors on ia64, ppc64 and sparc64 to accomodate references in
> block/blktrace.c and kernel/sched.c when CONFIG_SCHED_SMT is defined.
> 
> Warning: ppc64 and sparc64 have not yet been built nor tested.

These patches all seem to be unaltered from what I had.

The first patch (x86: remove x86_cpu_to_log_apicid array) is in Andi's
tree as x86_64-mm-remove-x86_cpu_to_log_apicid.patch so I don't apply that.

The sparc64/ppc64/ia64 convert-cpu_sibling_map-to-a-per_cpu-data-array
patches need to be folded into the base patch so that we don't break the build
at any stage.

So what I ended up with was

x86-fix-cpu_to_node-references.patch
x86-convert-cpu_core_map-to-be-a-per-cpu-variable.patch
convert-cpu_sibling_map-to-be-a-per-cpu-variable.patch
convert-cpu_sibling_map-to-a-per_cpu-data-array-ia64.patch
convert-cpu_sibling_map-to-a-per_cpu-data-array-ppc64.patch
convert-cpu_sibling_map-to-a-per_cpu-data-array-sparc64.patch
x86-convert-x86_cpu_to_apicid-to-be-a-per-cpu-variable.patch
x86-convert-cpu_llc_id-to-be-a-per-cpu-variable.patch

where the four convert-cpu_sibling_map-to-* will be clumped into a
single diff.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
