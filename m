Date: Tue, 27 Aug 2002 23:18:14 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] SImple Topology API v0.3 (1/2)
Message-ID: <20020827211814.GU25092@dualathlon.random>
References: <3D6537D3.3080905@us.ibm.com> <20020827143115.B39@toy.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20020827143115.B39@toy.ucw.cz>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@suse.cz>
Cc: Matthew Dobson <colpatch@us.ibm.com>, Andrew Morton <akpm@zip.com.au>, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Martin Bligh <mjbligh@us.ibm.com>, Michael Hohnbaum <hohnbaum@us.ibm.com>, lse-tech <lse-tech@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 27, 2002 at 02:31:16PM +0000, Pavel Machek wrote:
> Hi!
> 
> > Andrew, Linus, et al:
> > 	Here's the latest version of the Simple Topology API.  I've broken the patches 
> > into a solely in-kernel portion, and a portion that exposes the API to 
> > userspace via syscalls and prctl.  This patch (part 1) is the in-kernel part. 
> > I hope that the smaller versions of these patches will draw more feedback, 
> > comments, flames, etc.  Other than that, the patch remains relatively unchanged 
> > from the last posting.
> 
> > -   bool 'Multiquad NUMA system' CONFIG_MULTIQUAD
> > +   bool 'Multi-node NUMA system support' CONFIG_X86_NUMA
> 
> Why not simply CONFIG_NUMA?

that is just used by the common code, it fits well for that usage and it
has different semantics.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
