Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id AF0E36B01E3
	for <linux-mm@kvack.org>; Sat, 15 May 2010 13:08:23 -0400 (EDT)
From: Ed Tomlinson <edt@aei.ca>
Subject: Re: Defrag in shrinkers
Date: Sat, 15 May 2010 13:08:17 -0400
References: <1273821863-29524-1-git-send-email-david@fromorbit.com> <alpine.DEB.2.00.1005141244380.9466@router.home> <87y6fmmdak.fsf@basil.nowhere.org>
In-Reply-To: <87y6fmmdak.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201005151308.18090.edt@aei.ca>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Christoph Lameter <cl@linux.com>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, xfs@oss.sgi.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Friday 14 May 2010 16:36:03 Andi Kleen wrote:
> Christoph Lameter <cl@linux.com> writes:
> 
> > Would it also be possible to add some defragmentation logic when you
> > revise the shrinkers? Here is a prototype patch that would allow you to
> > determine the other objects sitting in the same page as a given object.
> >
> > With that I hope that you have enough information to determine if its
> > worth to evict the other objects as well to reclaim the slab page.
> 
> I like the idea, it would be useful for the hwpoison code too,
> when it tries to clean a page.

If this is done generally we probably want to retune the 'pressure' put on the slab.  The
whole reason for the callbacks was to keep the 'pressure on the slab proportional to the
memory pressure (scan rate).  

Ed Tomlinson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
