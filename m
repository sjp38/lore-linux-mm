Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id E1839800D8
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 05:28:32 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id f6so4247862wre.4
        for <linux-mm@kvack.org>; Thu, 25 Jan 2018 02:28:32 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s1si3720022wra.386.2018.01.25.02.28.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 Jan 2018 02:28:31 -0800 (PST)
Date: Thu, 25 Jan 2018 11:28:29 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [LSF/MM TOPIC] Patch Submission process and Handling Internal
 Conflict
Message-ID: <20180125102829.wr4xsps5gudpreac@quack2.suse.cz>
References: <1516820744.3073.30.camel@HansenPartnership.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1516820744.3073.30.camel@HansenPartnership.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, linux-scsi <linux-scsi@vger.kernel.org>, lsf-pc@lists.linux-foundation.org

On Wed 24-01-18 11:05:44, James Bottomley wrote:
> I've got two community style topics, which should probably be discussed
> in the plenary
> 
> 1. Patch Submission Process
> 
> Today we don't have a uniform patch submission process across Storage,
> Filesystems and MM.  The question is should we (or at least should we
> adhere to some minimal standards).  The standard we've been trying to
> hold to in SCSI is one review per accepted non-trivial patch.  For us,
> it's useful because it encourages driver writers to review each other's
> patches rather than just posting and then complaining their patch
> hasn't gone in.  I can certainly think of a couple of bugs I've had to
> chase in mm where the underlying patches would have benefited from
> review, so I'd like to discuss making the one review per non-trival
> patch our base minimum standard across the whole of LSF/MM; it would
> certainly serve to improve our Reviewed-by statistics.

Well, stuff like fs/reiserfs, fs/udf, fs/isofs, or fs/quota are also parts
of filesystem space but good luck with finding reviewers for those. 99% of
patches I sent in last 10 years were just met with silence (usually there's
0-1 developer interested in that code) so I just push them to have the bug
fixed... I don't feel that as a big problem since the code is reasonably
simple, can be tested, change rate is very low. I just wanted to give that
as an example that above rule does not work for everybody.

For larger filesystems I agree 'at least one reviewer' is a good rule. XFS
is known for this, I believe btrfs pretty much enforces it as well, Ted is
not enforcing this rule for ext4 AFAIK and often it is up to him to review
patches but larger / more complex stuff generally does get reviewed. So
IMO ext4 could use some improvement but I'll leave up to Ted to decide
what's better for ext4.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
