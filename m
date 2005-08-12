From: David Howells <dhowells@redhat.com>
In-Reply-To: <200508121329.46533.phillips@istop.com> 
References: <200508121329.46533.phillips@istop.com>  <200508110812.59986.phillips@arcor.de> <20050808145430.15394c3c.akpm@osdl.org> <26569.1123752390@warthog.cambridge.redhat.com> 
Subject: Re: [RFC][PATCH] Rename PageChecked as PageMiscFS 
Date: Fri, 12 Aug 2005 13:41:19 +0100
Message-ID: <5278.1123850479@warthog.cambridge.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@istop.com>
Cc: David Howells <dhowells@redhat.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Daniel Phillips <phillips@istop.com> wrote:

> You also achieved some sort of new low point in the abuse of StudlyCaps
> there.  Please, let's not get started on mixed case acronyms.

My patch has been around for quite a while, and no-one else has complained,
not even you before this point. Plus, you don't seem to be complaining about
PageSwapCache... nor even PageLocked.

I'm just requesting that you base your stuff on my patch that's already in
-mm. The names in there are already in use, though not currently in the -mm
patch (the patches that use it have been temporarily dropped).

> Anyway, it sounds like you want to bless the use of private page flags in
> filesystems. That is most probably a bad idea.

Just because you don't like it doesn't make it a bad idea or wrong.

Please then suggest an alternative way of doing this. Do you understand the
problem I'm trying to solve?

> Take a browse through the existing users and feast your eyes on the
> spectacular lack of elegance.

There may be plenty of inelegance in the kernel, but this comment isn't very
helpful. I've looked at an awful lot of code and cogitated much and tried
different ways of doing things. Currently this is the best I've come up with.

David
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
