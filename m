Date: Fri, 12 Aug 2005 14:28:20 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC][PATCH] Rename PageChecked as PageMiscFS 
In-Reply-To: <5278.1123850479@warthog.cambridge.redhat.com>
Message-ID: <Pine.LNX.4.61.0508121424280.3807@goblin.wat.veritas.com>
References: <200508121329.46533.phillips@istop.com>  <200508110812.59986.phillips@arcor.de>
 <20050808145430.15394c3c.akpm@osdl.org> <26569.1123752390@warthog.cambridge.redhat.com>
  <5278.1123850479@warthog.cambridge.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: Daniel Phillips <phillips@istop.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 12 Aug 2005, David Howells wrote:
> Daniel Phillips <phillips@istop.com> wrote:
> 
> I'm just requesting that you base your stuff on my patch that's already in
> -mm. The names in there are already in use, though not currently in the -mm
> patch (the patches that use it have been temporarily dropped).

Seconded: that would be fair, I see no reason to change your naming.

> > Anyway, it sounds like you want to bless the use of private page flags in
> > filesystems. That is most probably a bad idea.
> 
> Just because you don't like it doesn't make it a bad idea or wrong.

Seconded: I see no virtue in denying filesystems their one page flag.

Hugh
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
