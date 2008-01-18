Date: Fri, 18 Jan 2008 10:23:52 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 0/3] x86: Reduce memory and intra-node effects with
	large count NR_CPUs fixup
Message-ID: <20080118092352.GH24337@elte.hu>
References: <20080117223546.419383000@sgi.com> <478FD9D9.7030009@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <478FD9D9.7030009@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Mike Travis <travis@sgi.com> wrote:

> Hi Andrew,
> 
> My automatic scripts accidentally sent this mail prematurely.  Please 
> hold off applying yet.

I've picked it up for x86.git and i'll keep testing it (the patches seem 
straightforward) and will report any problems with the bite-head-off 
option unset.

[ The 32-bit NUMA compile issue is orthogonal to these patches - it's 
  due to the lack of 32-bit NUMA support in your changes :) That needs 
  fixing before this could go into v2.6.25. ]

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
