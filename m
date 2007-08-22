Date: Wed, 22 Aug 2007 21:56:45 +0200
From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 5/6] x86: fix cpu_to_node references
Message-ID: <20070822195645.GF8058@bingen.suse.de>
References: <20070822172101.138513000@sgi.com> <20070822172124.071200000@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070822172124.071200000@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: travis@sgi.com
Cc: Andi Kleen <ak@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 22, 2007 at 10:21:06AM -0700, travis@sgi.com wrote:
> Fix four instances where cpu_to_node is referenced
> by array instead of via the cpu_to_node macro.  This
> is preparation to moving it to the per_cpu data area.

Shouldn't this patch be logically before the per cpu 
conversion (which is 3/6). This way the result would
be git bisectable.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
