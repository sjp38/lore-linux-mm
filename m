Date: Tue, 15 Feb 2005 07:21:06 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC 2.6.11-rc2-mm2 0/7] mm: manual page migration -- overview
Message-Id: <20050215072106.508f65d2.pj@sgi.com>
In-Reply-To: <4211BD88.70904@sgi.com>
References: <20050212032535.18524.12046.26397@tomahawk.engr.sgi.com>
	<m1vf8yf2nu.fsf@muc.de>
	<20050212155426.GA26714@logos.cnet>
	<20050212212914.GA51971@muc.de>
	<20050214163844.GB8576@lnx-holt.americas.sgi.com>
	<20050214191509.GA56685@muc.de>
	<42113921.7070807@sgi.com>
	<20050214191651.64fc3347.pj@sgi.com>
	<4211BD88.70904@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: ak@muc.de, holt@sgi.com, marcelo.tosatti@cyclades.com, raybry@austin.rr.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Ray wrote:
> The exact ordering of when a task is moved to a new cpuset and when the
> migration occurs doesn't matter, AFAIK, if we accept the notion that
> a migrated task is in suspended state until after everything associated
> with it (including the new cpuset definition) is done.

The existance of _some_ sequence of system calls such that user space
could, if it so chose, do the 'right' thing does not exonerate the
kernel from enforcing its rules, on each call.

The kernel certainly does not have a crystal ball that lets it say "ok -
let this violation of my rules pass - I know that the caller will
straighten things out before it lets anything ontoward occur (before
it removes the suspension, in this case.)

In other words, more directly, the kernel must return from each system
call with everything in order, all its rules enforced.

I still think that migration should honor cpusets, unless you can show
me a good reason why that's too cumbersome.  At least a migration patch
for *-mm should honor cpusets.  When the migration patch goes into
Linus's main tree, then it should honor cpusets there too, if cpusets
are already there.  Or if migration goes into Linus's tree before
cpusets, the onus would be on cpusets to add the changes to the
migration code honoring cpusets, when and if cpusets followed along.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.650.933.1373, 1.925.600.0401
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
