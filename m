Date: Tue, 22 Apr 2003 11:55:00 -0400 (EDT)
From: Ingo Molnar <mingo@redhat.com>
Subject: Re: objrmap and vmtruncate
In-Reply-To: <20030422154248.GI8978@holomorphy.com>
Message-ID: <Pine.LNX.4.44.0304221152500.10400-100000@devserv.devel.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, Andrew Morton <akpm@digeo.com>, Andrea Arcangeli <andrea@suse.de>, mingo@elte.hu, hugh@veritas.com, dmccr@us.ibm.com, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 22 Apr 2003, William Lee Irwin III wrote:

> I have to apologize for my misstatements of the problem here. You
> yourself pointed out to me the hold time was, in fact, linear. Despite
> the linearity of the algorithm, the failure mode persists. I've
> postponed further investigation until later, when more invasive
> techniques are admissible; /proc/ alone will not suffice if linear
> algorithms under tasklist_lock can trigger this failure mode.

well, i have myself reproduced 30+ secs worth of pid-alloc related lockups
on my box, so it's was definitely not a fata morgana, and the
pid-allocation code was definitely quadratic near the PID-space saturation
point.

There might be something else still biting your system, i'd really be
interested in hearing more about it. What workload are you using to
trigger it?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
