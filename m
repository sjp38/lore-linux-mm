Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 634CB6B0037
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 16:04:17 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id y10so829215pdj.40
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 13:04:17 -0800 (PST)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTP id yy4si16808786pbc.69.2014.01.28.13.04.15
        for <linux-mm@kvack.org>;
        Tue, 28 Jan 2014 13:04:15 -0800 (PST)
Message-ID: <1390943052.16253.31.camel@dabdike>
Subject: Re: [Lsf-pc] [LSF/MM ATTEND] persistent transparent large
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Tue, 28 Jan 2014 13:04:12 -0800
In-Reply-To: <20140128193833.GD20939@parisc-linux.org>
References: <alpine.LSU.2.11.1401230334110.1414@eggly.anvils>
	 <20140128193833.GD20939@parisc-linux.org>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew@wil.cx>
Cc: Hugh Dickins <hughd@google.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org

On Tue, 2014-01-28 at 12:38 -0700, Matthew Wilcox wrote:
> On Thu, Jan 23, 2014 at 04:23:04AM -0800, Hugh Dickins wrote:
> > I'm eager to participate in this year's LSF/MM, but no topics of my
> > own to propose: I need to listen to what other people are suggesting.
> > 
> > Topics of most interest to me span mm and fs: persistent memory and
> > xip, transparent huge pagecache, large sectors, mm scalability.
> 
> I don't want to particularly pick on Hugh here; indeed, I know he won't
> take it personally which is why I've chosen to respoond to Hugh's message
> rather than any of the others.  I'm rather annoyed at the huge disrepancy
> between the number of people who are *saying* they're interested in
> persistent memory and the number of people who are reviewing patches
> relating to persistent memory.
> 
> As far as I'm concerned, the only people who have "earned" their way into
> attending the Summit based on contributing to persistent memory work
> would be Dave Chinner (er ... on the ctte already), Ted Ts'o (ditto),
> Jan Kara (ditto), Kirill Shutemov, Dave Hansen (who's not looking to
> attend this year), Ross Zwisler (ditto), and Andreas Dilger.

That rather depends on whether you think Execute In Place is the correct
way to handle persistent memory, I think?  I fully accept that it looks
like a good place to start since it's how all embedded systems handle
flash ... although looking at the proliferation of XIP hacks and
filesystems certainly doesn't give one confidence that they actually got
it right.

Fixing XIP looks like a good thing independent of whether it's the right
approach for persistent memory.  However, one thing that's missing for
the current patch sets is any buy in from the existing users ... can
they be persuaded to drop their hacks and adopt it (possibly even losing
some of the XIP specific filesystems), or will this end up as yet
another XIP hack?

Then there's the meta problem of is XIP the right approach.  Using
persistence within the current memory address space as XIP is a natural
fit for mixed volatile/NV systems, but what happens when they're all NV
memory?  Should we be discussing some VM based handling mechanisms for
persistent memory?

James




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
