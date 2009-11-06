Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1FB2F6B0044
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 19:01:19 -0500 (EST)
Date: Fri, 6 Nov 2009 01:01:13 +0100
Subject: Re: OOM killer, page fault
Message-ID: <20091106000113.GE22289@gamma.logic.tuwien.ac.at>
References: <20091102005218.8352.A69D9226@jp.fujitsu.com> <20091102135640.93de7c2a.minchan.kim@barrios-desktop> <28c262360911012300h4535118ewd65238c746b91a52@mail.gmail.com> <20091102155543.E60E.A69D9226@jp.fujitsu.com> <20091102140216.02567ff8.kamezawa.hiroyu@jp.fujitsu.com> <20091102141917.GJ2116@gamma.logic.tuwien.ac.at> <28c262360911020640k3f9dfcdct2cac6cc1d193144d@mail.gmail.com> <20091105132109.GA12676@gamma.logic.tuwien.ac.at> <loom.20091105T213323-393@post.gmane.org> <28c262360911051418r1aefbff6oa54a63d887c0ea48@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <28c262360911051418r1aefbff6oa54a63d887c0ea48@mail.gmail.com>
From: Norbert Preining <preining@logic.at>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Jody Belka <jody+lkml@jj79.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fr, 06 Nov 2009, Minchan Kim wrote:
> > Erm, could it not be due to the "return ret;" line being moved outside of the
> > if(), so that it always executes?
> 
> Right. Sorry it's my fault.
> I become  blind.
> 'return ret' should be inclueded in debug code.


Bummer, I'm blind, too, that was in fact obvious, since the codeflow
was changed. Could have seen that myself, sorry.

Recompiling already and trying to recreate the oom-killer boom.

Best wishes

Norbert

-------------------------------------------------------------------------------
Dr. Norbert Preining                                        Associate Professor
JAIST Japan Advanced Institute of Science and Technology   preining@jaist.ac.jp
Vienna University of Technology                               preining@logic.at
Debian Developer (Debian TeX Task Force)                    preining@debian.org
gpg DSA: 0x09C5B094      fp: 14DF 2E6C 0307 BE6D AD76  A9C0 D2BF 4AA3 09C5 B094
-------------------------------------------------------------------------------
I'm going to have a look.'
He glanced round at the others.
`Is no one going to say, "No you can't possibly, let me go
instead"?'
They all shook their heads.
`Oh well.'
                 --- Ford attempting to be heroic whilst being seiged by
                 --- Shooty and Bangbang.
                 --- Douglas Adams, The Hitchhikers Guide to the Galaxy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
