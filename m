Date: Fri, 16 May 2003 19:56:38 +0100
From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: [OOPS] 2.5.69-mm6
Message-ID: <20030516185638.GA19669@suse.de>
References: <20030516015407.2768b570.akpm@digeo.com> <87fznfku8z.fsf@lapper.ihatent.com> <20030516180848.GW8978@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030516180848.GW8978@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>, Alexander Hoogerhuis <alexh@ihatent.com>, Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 16, 2003 at 11:08:48AM -0700, William Lee Irwin III wrote:
 > On Fri, May 16, 2003 at 01:26:20PM +0200, Alexander Hoogerhuis wrote:
 > > This one goes in -mm5 as well, machine runs fine for a while in X, but
 > > trying to switch to a vty send the machine into the tall weeds...
 > 
 > Could you run with the radeon driver non-modular and kernel debugging
 > on? Then when it oopses could you use addr2line(1) to resolve this to
 > a line number?
 > 
 > I'm at something of a loss with respect to dealing with DRM in general.

Not that I'm pointing fingers, but it could be that
reslabify-pgds-and-pmds.patch again  ? Maybe it's still not quite right?
Might be worth backing out and retesting, just to rule it out.

		Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
