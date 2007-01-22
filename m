Date: Mon, 22 Jan 2007 11:15:46 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RPC][PATCH 2.6.20-rc5] limit total vfs page cache
In-Reply-To: <45B19483.6010300@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0701221114060.25121@schroedinger.engr.sgi.com>
References: <6d6a94c50701171923g48c8652ayd281a10d1cb5dd95@mail.gmail.com>
 <45B0DB45.4070004@linux.vnet.ibm.com>  <6d6a94c50701190805saa0c7bbgbc59d2251bed8537@mail.gmail.com>
  <45B112B6.9060806@linux.vnet.ibm.com>  <6d6a94c50701191804m79c70afdo1e664a072f928b9e@mail.gmail.com>
  <45B17D6D.2030004@yahoo.com.au> <6d6a94c50701191908i63fe7eebi9a97a4afb94f5df4@mail.gmail.com>
 <45B19483.6010300@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Aubrey Li <aubreylee@gmail.com>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, "linux-os (Dick Johnson)" <linux-os@analogic.com>, Robin Getz <rgetz@blackfin.uclinux.org>, "Hennerich, Michael" <Michael.Hennerich@analog.com>
List-ID: <linux-mm.kvack.org>

On Sat, 20 Jan 2007, Nick Piggin wrote:

> > It doesn't reduce the amount of memory available to the system. It
> > just reduce the amount of memory available to the page cache. So that
> > page cache is limited and the reserved memory can be allocated by the
> > application.
> 
> But the patch doesn't do that, as I explained.

The patch could do it if he would be checking NR_FILE_PAGES against 
a limit instead of the free pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
