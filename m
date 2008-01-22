Date: Tue, 22 Jan 2008 12:31:07 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] mmu notifiers #v3
In-Reply-To: <1201030127.6341.39.camel@lappy>
Message-ID: <Pine.LNX.4.64.0801221230340.28197@schroedinger.engr.sgi.com>
References: <20080113162418.GE8736@v2.random>  <20080116124256.44033d48@bree.surriel.com>
 <478E4356.7030303@qumranet.com>  <20080117162302.GI7170@v2.random>
 <478F9C9C.7070500@qumranet.com>  <20080117193252.GC24131@v2.random>
 <20080121125204.GJ6970@v2.random> <1201030127.6341.39.camel@lappy>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Izik Eidus <izike@qumranet.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm-devel@lists.sourceforge.net, Avi Kivity <avi@qumranet.com>, daniel.blueman@quadrics.com, holt@sgi.com, steiner@sgi.com, Andrew Morton <akpm@osdl.org>, Hugh Dickins <hugh@veritas.com>, Nick Piggin <npiggin@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Tue, 22 Jan 2008, Peter Zijlstra wrote:

> I think we can get rid of this rwlock as I think this will seriously
> hurt larger machines.

Correct.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
