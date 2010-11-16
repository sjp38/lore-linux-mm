Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 2A1838D0080
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 03:26:22 -0500 (EST)
Date: Tue, 16 Nov 2010 19:26:12 +1100
From: Nick Piggin <npiggin@kernel.dk>
Subject: Re: [patch] mm: vmscan implement per-zone shrinkers
Message-ID: <20101116082612.GA3709@amd>
References: <20101109123246.GA11477@amd>
 <20101114182614.BEE5.A69D9226@jp.fujitsu.com>
 <20101115092452.BEF1.A69D9226@jp.fujitsu.com>
 <20101116074717.GB3460@amd>
 <AANLkTi=BhuVn8F3ioTyR8S=J3LfJbuhYsMoHf9f=bvRn@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTi=BhuVn8F3ioTyR8S=J3LfJbuhYsMoHf9f=bvRn@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Anca Emanuel <anca.emanuel@gmail.com>
Cc: Nick Piggin <npiggin@kernel.dk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 16, 2010 at 09:53:19AM +0200, Anca Emanuel wrote:
> Nick, I want to test your tree.
> This is taking too long.
> Make something available now. And test it in real configs.

I'm working on it, I'll have another batch of patches out to look at
in a couple of hours, if stress testing holds up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
