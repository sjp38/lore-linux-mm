From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [patch 0/4] Cpu alloc V6: Replace percpu allocator in modules.c
Date: Wed, 1 Oct 2008 08:27:40 +1000
References: <20080929193500.470295078@quilx.com>
In-Reply-To: <20080929193500.470295078@quilx.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200810010827.42124.rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, ebiederm@xmission.com, travis@sgi.com, herbert@gondor.apana.org.au, xemul@openvz.org, penberg@cs.helsinki.fi
List-ID: <linux-mm.kvack.org>

On Tuesday 30 September 2008 05:35:00 Christoph Lameter wrote:
> Just do the bare mininum to establish a per cpu allocator. Later patchsets
> will gradually build out the functionality.

Hi Christoph,

   I'm not particularly attached to the allocator in module.c, and yours is 
more general.  And it's probably more efficient since most allocs are small.

> The most critical issue that came up awhile back was how to configure
> the size of the percpu area. Here we simply use a kernel parameter and use
> the static size of the existing percpu allocator for modules as a default.

Yerch.  OK, it *is* better than nothing.

Thanks for digging into this again,
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
