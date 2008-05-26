Date: Mon, 26 May 2008 10:23:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/3] explicitly document overloaded page flags V2
Message-Id: <20080526102309.01b9bc9a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <exportbomb.1211560342@pinky>
References: <exportbomb.1211560342@pinky>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Jeremy Fitzhardinge <jeremy@goop.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 23 May 2008 17:33:01 +0100
Andy Whitcroft <apw@shadowen.org> wrote:

> With the recent page flag reorganisation we have a single enum which
> defines the valid page flags and their values, nice and clear.  However
> there are a number of bits which are overloaded by different subsystems.
> Firstly there is PG_owner_priv_1 which is used by filesystems and by XEN.
> Secondly both SLOB and SLUB use a couple of extra page bits to manage
> internal state for pages they own; both overlay other bits.  All of these
> "aliases" are scattered about the source making it very hard for a reader
> to know if the bits are safe to rely on in all contexts; confusion here
> is bad.
> 
> As we now have a single place where the bits are clearly assigned it makes
> sense to clarify the reuse of bits by making the aliases explicit and
> visible with the original bit assignments.  This patch creates explicit
> aliases within the enum itself for the overloaded bits, creates standard
> bit accessors PageFoo etc. and uses those throughout.
> 
> This version pulls the bit manipulation out to standard named page bit
> accessors as suggested by Christoph, it retains the explicit mapping to
> the overlayed bits.  A fusion of both ideas.  This has been SLUB and
> SLOB have been compile tested on x86_64 only, and SLUB boot tested.
> If people feel this is worth doing then I can run a fuller set of testing.
> 
Thanks, I like this style of page-flags definition.

BTW, I have a quiestion as crash-dump user. With this 'enum' style, position of
each flags in page->flags depends on configs. Can we know what a bit means from
dump or bad_page()'s message ? (not a big problem now but..)

Thanks,
-Kame







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
