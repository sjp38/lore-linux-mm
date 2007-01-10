Date: Thu, 11 Jan 2007 10:08:55 +1100
From: David Chinner <dgc@sgi.com>
Subject: Re: [REGRESSION] 2.6.19/2.6.20-rc3 buffered write slowdown
Message-ID: <20070110230855.GF44411608@melbourne.sgi.com>
References: <20070110223731.GC44411608@melbourne.sgi.com> <Pine.LNX.4.64.0701101503310.22578@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0701101503310.22578@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: David Chinner <dgc@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 10, 2007 at 03:04:15PM -0800, Christoph Lameter wrote:
> On Thu, 11 Jan 2007, David Chinner wrote:
> 
> > The performance and smoothness is fully restored on 2.6.20-rc3
> > by setting dirty_ratio down to 10 (from the default 40), so
> > something in the VM is not working as well as it used to....
> 
> dirty_background_ratio is left as is at 10?

Yes.

> So you gain performance by switching off background writes via pdflush?

Well, pdflush appears to be doing very little on both 2.6.18 and
2.6.20-rc3. In both cases kswapd is consuming 10-20% of a CPU and
all of the pdflush threads combined (I've seen up to 7 active at
once) use maybe 1-2% of cpu time. This occurs regardless of the
dirty_ratio setting.

Cheers,

Dave.
-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
