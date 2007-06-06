Date: Wed, 6 Jun 2007 10:08:17 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: SLUB: Use ilog2 instead of series of constant comparisons.
Message-Id: <20070606100817.7af24b74.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0705211250410.27950@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0705211250410.27950@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Mon, 21 May 2007 12:51:47 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:

> I finally found a way to get rid of the nasty list of comparisions in
> slub_def.h. ilog2 seems to work right for constants.

This caused test.kernel.org's power4 build to blow up:

http://test.kernel.org/abat/93315/debug/test.log.0

fs/built-in.o(.text+0x148420): In function `.CalcNTLMv2_partial_mac_key':
: undefined reference to `.____ilog2_NaN'

it doesn't happen on my power4 toolchain so I expect it's some artifact
due to test.k.o's tendency to use crufty old toolchains.

arguably it's a bug in ilog2, dunno.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
