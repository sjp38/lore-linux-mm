Date: Wed, 30 Jul 2003 16:47:36 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [patch] 4G/4G split patch, 2.6.0-test1-G7
Message-ID: <220550000.1059608856@flay>
In-Reply-To: <Pine.LNX.4.44.0307192337050.13990-100000@localhost.localdomain>
References: <Pine.LNX.4.44.0307192337050.13990-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> the latest 4G/4G split patch can be found at:
> 
>    http://redhat.com/~mingo/4g-patches/4g-2.6.0-test1-mm1-G7
> 
> besides being a merge to 2.6.0-test-mm1, this version also includes many
> cleanups, bugfixes and speedups. All quirks are fixed and sysenter based
> syscalls work now too.

Any chance of getting a version of this against mainline? test1-mm1
crashes all the time for me, so it's impossible to test this ...
(doesn't apply cleanly to test2-mm1 either, I didn't look closely,
but presumably it's highpmd being dropped, etc).

M.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
