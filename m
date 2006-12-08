Message-ID: <4579DD22.70609@goop.org>
Date: Fri, 08 Dec 2006 13:46:10 -0800
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: new procfs memory analysis feature
References: <45789124.1070207@mvista.com> <20061207143611.7a2925e2.akpm@osdl.org> <Pine.LNX.4.64.0612081716440.28861@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <Pine.LNX.4.64.0612081716440.28861@weill.orchestra.cse.unsw.EDU.AU>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Cc: Andrew Morton <akpm@osdl.org>, David Singleton <dsingleton@mvista.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee.Schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

Paul Cameron Davies wrote:
> The PTI gathers all the open coded iterators togethers into one place,
> which would be a good precursor to providing generic iterators for
> non performance critical iterations.
>
> We are completing the updating/enhancements to this PTI for the latest
> kernel, to be released just prior to LCA.  This PTI is benchmarking
> well. We also plan to release the experimental guarded page table
> (GPT) running under this PTI.

I looked at implementing linear pagetable mappings for x86 as a way of
getting rid of CONFIG_HIGHPTE, and to make pagetable manipulations
generally more efficient.  I gave up on it after a while because all the
existing pagetable accessors are not suitable for a linear pagetable,
and I didn't want to have to introduce a pile of new pagetable
interfaces.  Would the PTI interface be helpful for this?

Thanks,
    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
