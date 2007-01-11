Date: Thu, 11 Jan 2007 13:57:37 +1100
From: David Chinner <dgc@sgi.com>
Subject: Re: [REGRESSION] 2.6.19/2.6.20-rc3 buffered write slowdown
Message-ID: <20070111025737.GZ33919298@melbourne.sgi.com>
References: <20070110223731.GC44411608@melbourne.sgi.com> <Pine.LNX.4.64.0701101503310.22578@schroedinger.engr.sgi.com> <20070110230855.GF44411608@melbourne.sgi.com> <45A57333.6060904@yahoo.com.au> <20070111003158.GT33919298@melbourne.sgi.com> <Pine.LNX.4.64.0701101642080.23729@schroedinger.engr.sgi.com> <20070111010605.GU33919298@melbourne.sgi.com> <Pine.LNX.4.64.0701101731590.24010@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0701101731590.24010@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: David Chinner <dgc@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 10, 2007 at 05:40:26PM -0800, Christoph Lameter wrote:
> On Thu, 11 Jan 2007, David Chinner wrote:
> 
> > On Wed, Jan 10, 2007 at 04:43:36PM -0800, Christoph Lameter wrote:
> > > You are comparing a debian 2.6.18 standard kernel with your tuned version 
> > > of 2.6.20-rc3. There may be a lot of differences. Could you get us the 
> > > config? Or use the same config file and build 2.6.20/18 the same way.
> > 
> > I took the /proc/config.gz from the debian 2.6.18-1 kernel as the
> > base config for the 2.6.20-rc3 kernel and did a make oldconfig on
> > it to make sure it was valid for the newer kernel but pretty much
> > the same. I think that's the right process, so I don't think
> > different build configs are the problem here.
> 
> Debian may have added extra patches that are not upstream. I see f.e. some 
> of my post 2.6.18 patches in there.

Did you read the thread I linked in my original report? The original
bug report was for a regression from 2.6.18.1 to 2.6.20-rc3. I have
reproduced the same regression between the debian 2.6.18-1 kernel
and 2.6.20-rc3. I think you're looking in the wrong place for the
cause of the problem....

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
