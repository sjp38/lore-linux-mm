Date: Sun, 6 Apr 2003 01:54:09 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: objrmap and vmtruncate
Message-ID: <20030406095409.GL993@holomorphy.com>
References: <20030404163154.77f19d9e.akpm@digeo.com> <12880000.1049508832@flay> <20030405024414.GP16293@dualathlon.random> <20030404192401.03292293.akpm@digeo.com> <20030405040614.66511e1e.akpm@digeo.com> <20030405232524.GD1828@holomorphy.com> <20030406052603.A4440@redhat.com> <20030406094128.GK993@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030406094128.GK993@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@redhat.com>, Andrew Morton <akpm@digeo.com>, andrea@suse.de, mbligh@aracnet.com, mingo@elte.hu, hugh@veritas.com, dmccr@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Apr 06, 2003 at 01:41:28AM -0800, William Lee Irwin III wrote:
> All this said, the drivers and the arch code bits are actually largely
> trivial substitions. If the discussion is truly limited to that, I'm
> okay with sending in pieces; still it makes me uneasy to do anything
> while the code I have now is so far from working as it truly should.

Also, part of this is prior agreement with Hugh (the originator of the
2.4.x version of the stuff) and akpm to withhold merging until full
functionality is achieved.

IMHO this full functionality has not been achieved, even though some
demonstrations of broadened hardware support benefits are feasible.

To both respect this agreement and remain within the bounds of my own
coding ethics, I should refuse to merge until both a greater degree of
completeness of implementation and a far greater degree of code
cleanliness is achieved.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
