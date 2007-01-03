Subject: Re: Alternative msync() fix for 2.6.18?
From: Jeff Licquia <licquia@debian.org>
In-Reply-To: <20061229140107.GG2062@deprecation.cyrius.com>
References: <20061226123106.GA32708@deprecation.cyrius.com>
	 <Pine.LNX.4.64.0612261305510.18364@blonde.wat.veritas.com>
	 <20061226132547.GC6256@deprecation.cyrius.com>
	 <Pine.LNX.4.64.0612261411580.20159@blonde.wat.veritas.com>
	 <Pine.LNX.4.64.0612270104020.11930@blonde.wat.veritas.com>
	 <20061229140107.GG2062@deprecation.cyrius.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Wed, 03 Jan 2007 09:32:07 -0500
Message-Id: <1167834727.3798.6.camel@xenpc.internal.licquia.org>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Michlmayr <tbm@cyrius.com>
Cc: Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, 394392@bugs.debian.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2006-12-29 at 15:01 +0100, Martin Michlmayr wrote:
> Yes, I agree.  I'm CCing the linux-mm list in hope that someone can
> review your patch.  In the meantime, I've asked the Debian LSB folks to
> verify that your patch fixes the LSB problem.

I am running the complete lsb-runtime-test suite against the new kernels
(as installed yesterday from the sid apt repo at
http://kernel-archive.buildserver.net/debian-kernel), but I also did a
run with just the msync test, which passed.  I will report the results
for the full suite when they become available.

FWIW, here's uname:

Linux xenpc 2.6.18-4-xen-686 #1 SMP Mon Jan 1 02:33:53 UTC 2007 i686 GNU/Linux

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
