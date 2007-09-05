Date: Wed, 5 Sep 2007 01:54:28 -0700 (PDT)
From: Martin Knoblauch <knobi@knobisoft.de>
Reply-To: knobi@knobisoft.de
Subject: Re: huge improvement with per-device dirty throttling
In-Reply-To: <20070822124736.GQ13915@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Message-ID: <831535.32703.qm@web32610.mail.mud.yahoo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>, Andi Kleen <andi@firstfloor.org>
Cc: "Jeffrey W. Baker" <jwbaker@acm.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--- Andrea Arcangeli <andrea@suse.de> wrote:

> On Wed, Aug 22, 2007 at 01:05:13PM +0200, Andi Kleen wrote:
> > Ok perhaps the new adaptive dirty limits helps your single disk
> > a lot too. But your improvements seem to be more "collateral
> damage" @)
> > 
> > But if that was true it might be enough to just change the dirty
> limits
> > to get the same effect on your system. You might want to play with
> > /proc/sys/vm/dirty_*
> 
> The adaptive dirty limit is per task so it can't be reproduced with
> global sysctl. It made quite some difference when I researched into
> it
> in function of time. This isn't in function of time but it certainly
> makes a lot of difference too, actually it's the most important part
> of the patchset for most people, the rest is for the corner cases
> that

> aren't handled right currently (writing to a slow device with
> writeback cache has always been hanging the whole thing).

 didn't see that remark before. I just realized that "slow device with
writeback cache" pretty well describes the CCISS controller in the
DL380g4. Could you elaborate why that is a problematic case?

Cheers
Martin

------------------------------------------------------
Martin Knoblauch
email: k n o b i AT knobisoft DOT de
www:   http://www.knobisoft.de

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
