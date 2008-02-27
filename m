Date: Wed, 27 Feb 2008 14:55:29 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch] my mmu notifiers
In-Reply-To: <20080219225923.GA18912@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0802271454430.13186@schroedinger.engr.sgi.com>
References: <20080219084357.GA22249@wotan.suse.de> <20080219135851.GI7128@v2.random>
 <20080219225923.GA18912@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrea Arcangeli <andrea@qumranet.com>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Tue, 19 Feb 2008, Nick Piggin wrote:

> I thought that could be used by a non-sleeping user (not intending
> to try supporting sleeping users). If it is useless then it should
> go away (BTW. I didn't see your recent patch, some of my confusion
> I think stems from Christoph's novel way of merging and splitting
> patches).

What is so novel about introducing functionality step by step?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
