Date: Sat, 24 Feb 2001 01:32:05 +0100 (CET)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: <mingo@elte.hu>
Subject: Re: RFC: vmalloc improvements
In-Reply-To: <200102240026.QAA09446@k2.llnl.gov>
Message-ID: <Pine.LNX.4.30.0102240129200.5327-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Reto Baettig <baettig@scs.ch>
Cc: MM Linux <linux-mm@kvack.org>, Kernel Linux <linux-kernel@vger.kernel.org>, Martin Frey <frey@scs.ch>
List-ID: <linux-mm.kvack.org>

On Fri, 23 Feb 2001, Reto Baettig wrote:

> We have an application that makes extensive use of vmalloc (we need
> lots of large virtual contiguous buffers. The buffers don't have to be
> physically contiguous).

question: what is this application, and why does it need so much virtual
memory? vmalloc()-able memory is maximized to 128 MB right now, and
increasing it conflicts with directly mapping RAM, so generally it's a
good idea to avoid vmalloc() as much as possible.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
