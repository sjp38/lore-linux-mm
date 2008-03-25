Date: Tue, 25 Mar 2008 11:54:38 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [PATCH] - Increase max physical memory size of x86_64
Message-ID: <20080325165438.GA5298@sgi.com>
References: <20080321133157.GA10911@sgi.com> <20080325164154.GA5909@alberich.amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080325164154.GA5909@alberich.amd.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andreas Herrmann <andreas.herrmann3@amd.com>
Cc: mingo@elte.hu, ak@suse.de, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 25, 2008 at 05:41:54PM +0100, Andreas Herrmann wrote:
> On Fri, Mar 21, 2008 at 08:31:57AM -0500, Jack Steiner wrote:
> > Increase the maximum physical address size of x86_64 system
> > to 44-bits. This is in preparation for future chips that
> > support larger physical memory sizes.
> 
> Shouldn't this be increased to 48?
> AMD family 10h CPUs actually support 48 bits for the
> physical address.

You are probably correct but I don't work with AMD processors
and don't understand their requirements. If someone
wants to submit a patch to support larger phys memory sizes,
I certainly have no objections....


--- jack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
