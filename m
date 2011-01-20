Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5BCBE8D003A
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 20:10:44 -0500 (EST)
Date: Thu, 20 Jan 2011 02:10:26 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: 2.6.38-rc1 problems with khugepaged
Message-ID: <20110120011026.GJ2232@cmpxchg.org>
References: <web-442414153@zbackend1.aha.ru>
 <20110119155954.GA2272@kryptos.osrc.amd.com>
 <20110119214523.GF2232@cmpxchg.org>
 <20110120000147.GR9506@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110120000147.GR9506@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: werner <w.landgraf@ru.ru>, Borislav Petkov <bp@amd64.org>, Ilya Dryomov <idryomov@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 20, 2011 at 01:01:47AM +0100, Andrea Arcangeli wrote:
> On Wed, Jan 19, 2011 at 10:45:23PM +0100, Johannes Weiner wrote:
> > Hi,
> > 
> > On Wed, Jan 19, 2011 at 04:59:54PM +0100, Borislav Petkov wrote:
> > > Adding some more parties to CC.
> > > 
> > > On Wed, Jan 19, 2011 at 09:45:25AM -0400, werner wrote:
> > > > **  Help   Help Help ***
> > > > 
> > > > My computer crashs on booting  ...   :( :(
> > 
> > That sucks!
> > 
> > I cross-compiled for 32-bit and was able to match up the disassembly
> > against the code line from your oops report.  Apparently the pte was
> > an invalid pointer, and it makes perfect sense: we unmap the highpte
> > _before_ we access the pointer again for __collapse_huge_page_copy().
> > 
> > Can you test with this fix applied?  It is only compile-tested, I too
> > have no 32-bit installations anymore.
> 
> Thanks Johannes, I already sent the same fix a few minutes ago, it is
> also confirmed to work from Ilya in Message-ID:
> <20110119224950.GA3429@kwango.lan.net>

Actually, I sent it half an hour before you ;-) But good to see that
it fixes the problem.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
