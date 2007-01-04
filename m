Subject: Re: Alternative msync() fix for 2.6.18?
From: Jeff Licquia <jeff@licquia.org>
In-Reply-To: <1167834727.3798.6.camel@xenpc.internal.licquia.org>
References: <20061226123106.GA32708@deprecation.cyrius.com>
	 <Pine.LNX.4.64.0612261305510.18364@blonde.wat.veritas.com>
	 <20061226132547.GC6256@deprecation.cyrius.com>
	 <Pine.LNX.4.64.0612261411580.20159@blonde.wat.veritas.com>
	 <Pine.LNX.4.64.0612270104020.11930@blonde.wat.veritas.com>
	 <20061229140107.GG2062@deprecation.cyrius.com>
	 <1167834727.3798.6.camel@xenpc.internal.licquia.org>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Thu, 04 Jan 2007 08:35:56 -0500
Message-Id: <1167917756.6606.0.camel@xenpc.internal.licquia.org>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Michlmayr <tbm@cyrius.com>
Cc: Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, 394392@bugs.debian.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-01-03 at 09:32 -0500, Jeff Licquia wrote:
> I am running the complete lsb-runtime-test suite against the new kernels
> (as installed yesterday from the sid apt repo at
> http://kernel-archive.buildserver.net/debian-kernel), but I also did a
> run with just the msync test, which passed.  I will report the results
> for the full suite when they become available.

Those results are in.  No additional failures are caused by the new
kernels.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
