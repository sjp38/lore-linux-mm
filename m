Date: Sun, 6 Apr 2003 05:29:43 -0400
From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: objrmap and vmtruncate
Message-ID: <20030406052943.B4440@redhat.com>
References: <20030404163154.77f19d9e.akpm@digeo.com> <12880000.1049508832@flay> <20030405024414.GP16293@dualathlon.random> <20030404192401.03292293.akpm@digeo.com> <20030405040614.66511e1e.akpm@digeo.com> <20030405163003.GD1326@dualathlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030405163003.GD1326@dualathlon.random>; from andrea@suse.de on Sat, Apr 05, 2003 at 06:30:03PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Andrew Morton <akpm@digeo.com>, mbligh@aracnet.com, mingo@elte.hu, hugh@veritas.com, dmccr@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Apr 05, 2003 at 06:30:03PM +0200, Andrea Arcangeli wrote:
> 
> I'm not questioning during paging rmap is more efficient than objrmap,
> but your argument about rmap having lower complexity of objrmap and that
> rmap is needed is wrong. The fact is that with your 100 mappings per
> each of the 100 tasks case, both algorithms works in O(N) where N is
> the number of the pagetables mapping the page. No difference in

Small mistake on your part: there are two different parameters to that:
objrmap is O(N) where N is the number of vmas, and regular rmap is O(M) 
where M is the number of currently mapped ptes.  M <= N and is frequently 
less for sparsely resident pages (ie in things like executables).

		-ben
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
