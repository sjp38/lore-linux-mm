Date: Mon, 14 Feb 2005 19:16:51 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC 2.6.11-rc2-mm2 0/7] mm: manual page migration -- overview
Message-Id: <20050214191651.64fc3347.pj@sgi.com>
In-Reply-To: <42113921.7070807@sgi.com>
References: <20050212032535.18524.12046.26397@tomahawk.engr.sgi.com>
	<m1vf8yf2nu.fsf@muc.de>
	<20050212155426.GA26714@logos.cnet>
	<20050212212914.GA51971@muc.de>
	<20050214163844.GB8576@lnx-holt.americas.sgi.com>
	<20050214191509.GA56685@muc.de>
	<42113921.7070807@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: ak@muc.de, holt@sgi.com, marcelo.tosatti@cyclades.com, raybry@austin.rr.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Ray wrote:
> [Thus the disclaimer in
> the overview note that we have figured all the interaction with
> memory policy stuff yet.]

Does the same disclaimer apply to cpusets?

Unless it causes some undo pain, I would think that page migration
should _not_ violate a tasks cpuset.  I guess this means that a typical
batch manager would move a task to its new cpuset on the new nodes, or
move the cpuset containing some tasks to their new nodes, before asking
the page migrator to drag along the currently allocated pages from the
old location.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.650.933.1373, 1.925.600.0401
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
