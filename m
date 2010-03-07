Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 4E7086B0047
	for <linux-mm@kvack.org>; Sat,  6 Mar 2010 20:03:36 -0500 (EST)
Date: Sun, 7 Mar 2010 12:03:27 +1100
From: Paul Mackerras <paulus@samba.org>
Subject: Re: please don't apply : bootmem: avoid DMA32 zone by default
Message-ID: <20100307010327.GD15725@brick.ozlabs.ibm.com>
References: <49b004811003041321g2567bac8yb73235be32a27e7c@mail.gmail.com>
 <20100305032106.GA12065@cmpxchg.org>
 <49b004811003042117n720f356h7e10997a1a783475@mail.gmail.com>
 <4B915074.4020704@kernel.org>
 <4B916BD6.8010701@kernel.org>
 <4B91EBC6.6080509@kernel.org>
 <20100306162234.e2cc84fb.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100306162234.e2cc84fb.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Yinghai Lu <yinghai@kernel.org>, Greg Thelen <gthelen@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, Mar 06, 2010 at 04:22:34PM -0800, Andrew Morton wrote:
> Earlier, Johannes wrote
> 
> : Humm, now that is a bit disappointing.  Because it means we will never
> : get rid of bootmem as long as it works for the other architectures. 
> : And your changeset just added ~900 lines of code, some of it being a
> : rather ugly compatibility layer in bootmem that I hoped could go away
> : again sooner than later.

Whoa!  Who's proposing to get rid of bootmem, and why?

Paul.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
