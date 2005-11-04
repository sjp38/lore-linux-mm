Date: Thu, 3 Nov 2005 22:10:37 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
Message-Id: <20051103221037.33ae0f53.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.64.0511032105110.27915@g5.osdl.org>
References: <20051104010021.4180A184531@thermo.lanl.gov>
	<Pine.LNX.4.64.0511032105110.27915@g5.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: andy@thermo.lanl.gov, mbligh@mbligh.org, akpm@osdl.org, arjan@infradead.org, arjanv@infradead.org, haveblue@us.ibm.com, kravetz@us.ibm.com, lhms-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mel@csn.ul.ie, mingo@elte.hu, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

Linus wrote:
> Maybe you'd be willing on compromising by using a few kernel boot-time 
> command line options for your not-very-common load.

If we were only a few options away from running Andy's varying load
mix with something close to ideal performance, we'd be in fat city,
and Andy would never have been driven to write that rant.

There's more to it than that, but it is not as impossible as a battery
with the efficiencies you (and the rest of us) dream of.

Andy has used systems that resemble what he is seeking.  So he is not
asking for something clearly impossible.  Though it might not yet be
possible, in ways that contribute to a continuing healthy kernel code
base.

It's an interesting challenge - finding ways to improve the kernel's
performance on such high end loads, that are also suitable and
desirable (or at least innocent enough) for inclusion in a kernel far
more widely used in embeddeds, desktops and ordinary servers.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
