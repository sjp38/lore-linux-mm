Date: Wed, 19 Sep 2007 16:37:13 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: VM/VFS bug with large amount of memory and file systems?
Message-Id: <20070919163713.6d0f752c.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0709191628170.3971@schroedinger.engr.sgi.com>
References: <C2A8AED2-363F-4131-863C-918465C1F4E1@cam.ac.uk>
	<1189850897.21778.301.camel@twins>
	<20070915035228.8b8a7d6d.akpm@linux-foundation.org>
	<13126578-A4F8-43EA-9B0D-A3BCBFB41FEC@cam.ac.uk>
	<20070917163257.331c7605@twins>
	<46EEB532.3060804@redhat.com>
	<20070917131526.e8db80fe.akpm@linux-foundation.org>
	<46EEE7B7.1070206@redhat.com>
	<20070917141127.ab2ae148.akpm@linux-foundation.org>
	<46F19ED6.20501@redhat.com>
	<20070919154542.4ed8ea1e.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0709191628170.3971@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Anton Altaparmakov <aia21@cam.ac.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, marc.smith@esmail.mcc.edu
List-ID: <linux-mm.kvack.org>

On Wed, 19 Sep 2007 16:29:02 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Wed, 19 Sep 2007, Andrew Morton wrote:
> 
> > Cool.
> 
> Should I rediff on top of rc6-mm1 for submission? When will you be able to 
> take it?
>  

erm, I spose we should be concentrating on stabilising the current pile of
crud for 2.6.24 - it sure needs it.

Sometime around 2.6.24-rc1 would suit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
