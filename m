Date: Tue, 18 Mar 2003 16:09:02 +0000
From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: 2.5.65-mm1
Message-ID: <20030318160902.C21945@flint.arm.linux.org.uk>
References: <20030318031104.13fb34cc.akpm@digeo.com> <87adfs4sqk.fsf@lapper.ihatent.com> <87bs08vfkg.fsf@lapper.ihatent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87bs08vfkg.fsf@lapper.ihatent.com>; from alexh@ihatent.com on Tue, Mar 18, 2003 at 04:51:11PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Hoogerhuis <alexh@ihatent.com>
Cc: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 18, 2003 at 04:51:11PM +0100, Alexander Hoogerhuis wrote:
> Oh well, I've had one hang within 10 minutes of booting, came back and
> the machine was unresponsive (mouse and keyboard under X, unable to
> switch to console). Apart from that I've got two funnies in my boot
> messages:

Could you send the full bus information for all devices (lspci -vv),
and the contents of /proc/iomem and /proc/ioports ?

I don't believe there's anything in my PCI updates which should have
changed the behaviour - they were touching mainly the scanning for
devices, and the way we write resources back into the hardware.  The
latter rarely happens on x86, except for cardbus devices.

-- 
Russell King (rmk@arm.linux.org.uk)                The developer of ARM Linux
             http://www.arm.linux.org.uk/personal/aboutme.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
