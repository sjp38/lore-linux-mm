From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 0/2] x86: Reduce pressure on stack from cpumask usage -v2
Date: Wed, 21 Nov 2007 11:18:44 +0100
References: <20071121100201.156191000@sgi.com>
In-Reply-To: <20071121100201.156191000@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200711211118.45137.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: travis@sgi.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, mingo@elte.hu, apw@shadowen.org, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wednesday 21 November 2007 11:02:01 travis@sgi.com wrote:
> 
> v2:
>     - fix some compile errors when NR_CPUS > default for ia386 (128 & 4096)
>     - remove unneccessary includes
> 
> Convert cpumask_of_cpu to use a static percpu data array and
> set_cpus_allowed to pass the cpumask_t arg as a pointer.

I'm not sure that is too useful alone because you didn't solve the
set_cpus_allowed(oldmask) problem.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
