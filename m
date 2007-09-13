From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 00/10] x86: Reduce Memory Usage and Inter-Node message traffic (v3)
Date: Thu, 13 Sep 2007 11:53:32 +0200
References: <20070912015644.927677070@sgi.com>
In-Reply-To: <20070912015644.927677070@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200709131153.32576.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: travis@sgi.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, sparclinux@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wednesday 12 September 2007 03:56, travis@sgi.com wrote:
> Note:
>
> This patch consolidates all the previous patches regarding
> the conversion of static arrays sized by NR_CPUS into per_cpu
> data arrays and is referenced against 2.6.23-rc6 .


Looks good to me from the x86 side. I'll leave it to Andrew to
handle for now though because it touches too many files
outside x86.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
