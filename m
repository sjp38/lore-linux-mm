Date: Tue, 31 Oct 2000 11:48:51 +0100
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: Re: kmalloc() allocation.
Message-ID: <20001031114851.D7204@nightmaster.csn.tu-chemnitz.de>
References: <Pine.LNX.3.95.1001030104956.735A-100000@chaos.analogic.com> <Pine.LNX.4.21.0010301439080.16609-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0010301439080.16609-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Mon, Oct 30, 2000 at 02:40:16PM -0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Richard B. Johnson" <root@chaos.analogic.com>, Linux kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Oct 30, 2000 at 02:40:16PM -0200, Rik van Riel wrote:
> > There are 256 megabytes of SDRAM available. I don't think it's
> > reasonable that a 1/2 megabyte allocation would fail, especially
> > since it's the first module being installed.
> If you write the defragmentation code for the VM, I'll
> be happy to bump up the limit a bit ...

Should become easier once we start doing physical page scannings.

We could record physical continous freeable areas on the fly
then. If someone asks for them later, we recheck whether they
still exists and free (inactive_clean) or remap (active or
inactive_dirty) the whole area, whether they are used or not. 

This could still be improved by using up smallest fit areas
first for kmalloc() based on these areas.

But beware: We just have a good hint here, which needs to be
   rechecked every time we allocate such areas to become
   guarantee.

Rik: What do you think about this (physical cont. area cache) for 2.5?

Regards

Ingo Oeser
-- 
Feel the power of the penguin - run linux@your.pc
<esc>:x
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
