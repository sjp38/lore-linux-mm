Date: Wed, 9 Jul 2003 02:29:07 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.74-mm3
Message-ID: <20030709092907.GO15452@holomorphy.com>
References: <20030708223548.791247f5.akpm@osdl.org> <20030709092433.GA27280@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030709092433.GA27280@waste.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 09, 2003 at 04:24:33AM -0500, Matt Mackall wrote:
> -#define apm_save_cpus()	0
> +#define apm_save_cpus()	(current->cpus_allowed)
>  #define apm_restore_cpus(x)	(void)(x)

It's trying to describe an empty set of cpus. This is denoted by
CPU_MASK_NONE in the cpumask_t bits.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
