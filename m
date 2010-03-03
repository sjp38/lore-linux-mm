Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 472A46B0047
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 09:34:55 -0500 (EST)
Date: Wed, 3 Mar 2010 15:34:50 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [patch] slab: add memory hotplug support
Message-ID: <20100303143450.GA25500@basil.fritz.box>
References: <alpine.DEB.2.00.1002242357450.26099@chino.kir.corp.google.com> <alpine.DEB.2.00.1002251228140.18861@router.home> <20100226114136.GA16335@basil.fritz.box> <alpine.DEB.2.00.1002260904311.6641@router.home> <20100226155755.GE16335@basil.fritz.box> <alpine.DEB.2.00.1002261123520.7719@router.home> <alpine.DEB.2.00.1002261555030.32111@chino.kir.corp.google.com> <alpine.DEB.2.00.1003010224170.26824@chino.kir.corp.google.com> <20100302125306.GD19208@basil.fritz.box> <84144f021003020704s3abafc24t9b8ab34234094b79@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84144f021003020704s3abafc24t9b8ab34234094b79@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Andi Kleen <andi@firstfloor.org>, David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@suse.de>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> > The patch looks far more complicated than my simple fix.
> 
> I wouldn't exactly call the fallback_alloc() games "simple".

I have to disagree on that.  It was the most simple fix I could
come up with, least intrusive to legacy like slab is.

> > Is more complicated now better?
> 
> Heh, heh. You can't post the oops, you don't want to rework your

The missing oops was about the timer race, not about this one.

> patches as per review comments, and now you complain about David's
> patch without one bit of technical content. I'm sorry but I must

Well sorry I'm just a bit frustrated about the glacial progress on what
should be relatively straight forward fixes.

IMHO something like my patch should have gone into .33 and any more
complicated reworks like this into .34.

> But anyway, if you have real technical concerns over the patch, please
> make them known; otherwise I'd much appreciate a Tested-by tag from
> you for David's patch.

If it works it would be ok for me. The main concern would be to actually
get it fixed.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
