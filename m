Date: Tue, 7 Oct 2008 16:34:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 0/4] Cpu alloc V6: Replace percpu allocator in modules.c
Message-Id: <20081007163449.0716be54.akpm@linux-foundation.org>
In-Reply-To: <20080929193500.470295078@quilx.com>
References: <20080929193500.470295078@quilx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, rusty@rustcorp.com.au, jeremy@goop.org, ebiederm@xmission.com, travis@sgi.com, herbert@gondor.apana.org.au, xemul@openvz.org, penberg@cs.helsinki.fi
List-ID: <linux-mm.kvack.org>

On Mon, 29 Sep 2008 12:35:00 -0700
Christoph Lameter <cl@linux-foundation.org> wrote:

> Just do the bare mininum to establish a per cpu allocator. Later patchsets
> will gradually build out the functionality.

I need to drop these - the dynalloc thing (I don't think I even know
what it does) in Ingo's trees make changes all over the place and
nothing much applies any more.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
