Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6375F6B0055
	for <linux-mm@kvack.org>; Fri, 29 May 2009 17:50:36 -0400 (EDT)
Date: Fri, 29 May 2009 22:52:02 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] [0/16] HWPOISON: Intro
Message-ID: <20090529225202.0c61a4b3@lxorguk.ukuu.org.uk>
In-Reply-To: <200905291135.124267638@firstfloor.org>
References: <200905291135.124267638@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

On Fri, 29 May 2009 23:35:25 +0200 (CEST)
Andi Kleen <andi@firstfloor.org> wrote:

> 
> Another version of the hwpoison patchkit. I addressed 
> all feedback, except:
> I didn't move the handlers into other files for now, prefer
> to keep things together for now
> I'm keeping an own pagepoison bit because I think that's 
> cleaner than any other hacks.
> 
> Andrew, please put it into mm for .31 track.

Andrew please put it on the "Andi needs to justify his pageflags" non-path

I'm with Rik on this - we may have a few pageflags handy now but being
slack with them for an obscure feature that can be done other ways and
isn't performance critical is just lazy and bad planning for the long
term.

Andi - "I'm doing it my way so nyahh, put it into .31" doesn't fly. If
you want it in .31 convince Rik and me and others that its a good use of
a pageflag.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
