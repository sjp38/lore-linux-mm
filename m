From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 3/6] x86: Convert cpu_sibling_map to be a per cpu variable (v2)
Date: Sat, 1 Sep 2007 16:06:48 +0200
References: <20070824222654.687510000@sgi.com> <20070824222948.851896000@sgi.com> <20070831194903.5d88a007.akpm@linux-foundation.org>
In-Reply-To: <20070831194903.5d88a007.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200709011606.49208.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: travis@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Saturday 01 September 2007 04:49, Andrew Morton wrote:
> On Fri, 24 Aug 2007 15:26:57 -0700 travis@sgi.com wrote:
> > Convert cpu_sibling_map from a static array sized by NR_CPUS to a
> > per_cpu variable.  This saves sizeof(cpumask_t) * NR unused cpus.
> > Access is mostly from startup and CPU HOTPLUG functions.

The patchset was broken anyways even on x86-64 because of the 
ordering issues at early boot Suresh pointed out.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
