Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 285456B0031
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 20:52:43 -0500 (EST)
Received: by mail-wg0-f41.google.com with SMTP id n12so7171929wgh.4
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 17:52:42 -0800 (PST)
Received: from mail.parisc-linux.org (palinux.external.hp.com. [192.25.206.14])
        by mx.google.com with ESMTPS id ui5si233845wjc.22.2014.01.28.17.52.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 28 Jan 2014 17:52:41 -0800 (PST)
Date: Tue, 28 Jan 2014 18:52:39 -0700
From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [LSF/MM ATTEND] persistent transparent large
Message-ID: <20140129015238.GE20939@parisc-linux.org>
References: <alpine.LSU.2.11.1401230334110.1414@eggly.anvils> <20140128193833.GD20939@parisc-linux.org> <alpine.LSU.2.11.1401281213490.1633@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1401281213490.1633@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Tue, Jan 28, 2014 at 12:42:08PM -0800, Hugh Dickins wrote:
> On Tue, 28 Jan 2014, Matthew Wilcox wrote:
> > On Thu, Jan 23, 2014 at 04:23:04AM -0800, Hugh Dickins wrote:
> > > I'm eager to participate in this year's LSF/MM, but no topics of my
> > > own to propose: I need to listen to what other people are suggesting.
> > > 
> > > Topics of most interest to me span mm and fs: persistent memory and
> > > xip, transparent huge pagecache, large sectors, mm scalability.
> > 
> > I don't want to particularly pick on Hugh here; indeed, I know he won't
> > take it personally which is why I've chosen to respoond to Hugh's message
> 
> Sure, your remarks are completely appropriate, and very well directed.

Thanks.  You're a long-time contributor in so many ways to the VM that I
know this won't prejudice the program committee against you.

> > rather than any of the others.  I'm rather annoyed at the huge disrepancy
> > between the number of people who are *saying* they're interested in
> > persistent memory and the number of people who are reviewing patches
> > relating to persistent memory.
> 
> It's fair enough, though, for people to express an interest in a topic,
> without having time to contribute to it beforehand.  That does not earn
> anyone a place, but may help the committee to choose between topics.

Absolutely.  And it might help convince the program committee to invite
someone if they were seen to be active ... ;-)

> > I'd particularly like a VM person to review these two patches:
> > 
> > http://marc.info/?l=linux-fsdevel&m=138983598101510&w=2
> > http://marc.info/?l=linux-fsdevel&m=138983600001513&w=2
> 
> I'd love to give you a constructive answer, but I'm not going to
> comment on 2 out of 22 without getting to grips with the 22.  You've
> been thinking about this stuff for months: others need time too,
> and this is far from the only patchset on their queues.

The first one is stand-alone.  It fixes a bug that has been around for
years ... but nobody noticed because nobody uses XIP.

The second is a little more involved with the rest of the patchset,
and I'd totally understand anyone wanting to review it in conjunction
with the rest of the patchset.

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
