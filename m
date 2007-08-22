Subject: Re: huge improvement with per-device dirty throttling
References: <1187764638.6869.17.camel@hannibal>
From: Andi Kleen <andi@firstfloor.org>
Date: 22 Aug 2007 13:05:13 +0200
In-Reply-To: <1187764638.6869.17.camel@hannibal>
Message-ID: <p733aybzv6e.fsf@bingen.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Jeffrey W. Baker" <jwbaker@acm.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Jeffrey W. Baker" <jwbaker@acm.org> writes:
> 
> My system is a Core 2 Duo, 2GB, single SATA disk.

Hmm, I thought the patch was only supposed to make a real difference
if you have multiple devices? But you only got a single disk.   

At least that was the case  it was supposed to fix: starvation of fast 
devices from slow devices.

Ok perhaps the new adaptive dirty limits helps your single disk
a lot too. But your improvements seem to be more "collateral damage" @)

But if that was true it might be enough to just change the dirty limits
to get the same effect on your system. You might want to play with
/proc/sys/vm/dirty_*

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
