From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [patch 4/4] cpu alloc: Use cpu allocator instead of the builtin modules per cpu allocator
Date: Wed, 1 Oct 2008 08:28:43 +1000
References: <20080929193500.470295078@quilx.com> <20080929193516.500912533@quilx.com>
In-Reply-To: <20080929193516.500912533@quilx.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200810010828.44521.rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, ebiederm@xmission.com, travis@sgi.com, herbert@gondor.apana.org.au, xemul@openvz.org, penberg@cs.helsinki.fi
List-ID: <linux-mm.kvack.org>

On Tuesday 30 September 2008 05:35:04 Christoph Lameter wrote:
> Remove the builtin per cpu allocator from modules.c and use cpu_alloc
> instead.
>
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

Acked-by: Rusty Russell <rusty@rustcorp.com.au>

Thanks,
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
