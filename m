Date: Thu, 22 Jun 2006 23:50:45 -0400
From: Jeff Dike <jdike@addtoit.com>
Subject: Re: [PATCH] mm: tracking shared dirty pages -v10
Message-ID: <20060623035045.GA8968@ccure.user-mode-linux.org>
References: <20060619175243.24655.76005.sendpatchset@lappy> <20060619175253.24655.96323.sendpatchset@lappy> <Pine.LNX.4.64.0606222126310.26805@blonde.wat.veritas.com> <1151019590.15744.144.camel@lappy> <20060623031012.GA8395@ccure.user-mode-linux.org> <20060622203123.affde061.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060622203123.affde061.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: hpa@zytor.com, a.p.zijlstra@chello.nl, hugh@veritas.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dhowells@redhat.com, christoph@lameter.com, mbligh@google.com, npiggin@suse.de, torvalds@osdl.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 22, 2006 at 08:31:23PM -0700, Andrew Morton wrote:
> That's probably a parallel kbuild race.  Type `make' again ;)

Nope, it's extremely consistent, including with a non-parallel build.

				Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
