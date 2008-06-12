Date: Wed, 11 Jun 2008 23:34:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: repeatable slab corruption with LTP msgctl08
Message-Id: <20080611233449.08e6eaa0.akpm@linux-foundation.org>
In-Reply-To: <20080611221324.42270ef2.akpm@linux-foundation.org>
References: <20080611221324.42270ef2.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nadia Derbey <Nadia.Derbey@bull.net>, Manfred Spraul <manfred@colorfullife.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, 11 Jun 2008 22:13:24 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:

> Running current mainline on my old 2-way PIII.  Distro is RH FC1.  LTP
> version is ltp-full-20070228 (lots of retro-computing there).
> 
> Config is at http://userweb.kernel.org/~akpm/config-vmm.txt
> 
> 
> ./testcases/bin/msgctl08 crashes after ten minutes or so:

ah, it runs to completion in about ten seconds on 2.6.25, so it'll be
easy for someone to bisect it.

What's that?  Sigh.  OK.  I wasn't doing anything much anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
