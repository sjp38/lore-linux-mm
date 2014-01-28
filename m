Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 9C4906B0037
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 14:38:40 -0500 (EST)
Received: by mail-wg0-f50.google.com with SMTP id l18so1702038wgh.29
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 11:38:39 -0800 (PST)
Received: from mail.parisc-linux.org (palinux.external.hp.com. [192.25.206.14])
        by mx.google.com with ESMTPS id l14si907126wjq.66.2014.01.28.11.38.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 28 Jan 2014 11:38:36 -0800 (PST)
Date: Tue, 28 Jan 2014 12:38:33 -0700
From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [LSF/MM ATTEND] persistent transparent large
Message-ID: <20140128193833.GD20939@parisc-linux.org>
References: <alpine.LSU.2.11.1401230334110.1414@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1401230334110.1414@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Thu, Jan 23, 2014 at 04:23:04AM -0800, Hugh Dickins wrote:
> I'm eager to participate in this year's LSF/MM, but no topics of my
> own to propose: I need to listen to what other people are suggesting.
> 
> Topics of most interest to me span mm and fs: persistent memory and
> xip, transparent huge pagecache, large sectors, mm scalability.

I don't want to particularly pick on Hugh here; indeed, I know he won't
take it personally which is why I've chosen to respoond to Hugh's message
rather than any of the others.  I'm rather annoyed at the huge disrepancy
between the number of people who are *saying* they're interested in
persistent memory and the number of people who are reviewing patches
relating to persistent memory.

As far as I'm concerned, the only people who have "earned" their way into
attending the Summit based on contributing to persistent memory work
would be Dave Chinner (er ... on the ctte already), Ted Ts'o (ditto),
Jan Kara (ditto), Kirill Shutemov, Dave Hansen (who's not looking to
attend this year), Ross Zwisler (ditto), and Andreas Dilger.

I'd particularly like a VM person to review these two patches:

http://marc.info/?l=linux-fsdevel&m=138983598101510&w=2
http://marc.info/?l=linux-fsdevel&m=138983600001513&w=2

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
