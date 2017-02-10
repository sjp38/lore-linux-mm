Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id D891B6B0038
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 09:55:35 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id t18so11491309wmt.7
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 06:55:35 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l187si1474176wml.150.2017.02.10.06.55.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Feb 2017 06:55:34 -0800 (PST)
Date: Fri, 10 Feb 2017 15:55:33 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] slab reclaim
Message-ID: <20170210145532.GQ10893@dhcp22.suse.cz>
References: <20161228130949.GA11480@dhcp22.suse.cz>
 <20170102110257.GB18058@quack2.suse.cz>
 <b3e28101-1129-d2bc-8695-e7f7529a1442@suse.cz>
 <alpine.DEB.2.20.1701301243470.2833@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1701301243470.2833@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Mon 30-01-17 12:47:04, Cristopher Lameter wrote:
> On Thu, 5 Jan 2017, Vlastimil Babka wrote:
> 
> >
> > Yeah, some of the related stuff that was discussed at Kernel Summit [1]
> > would be nice to have at least prototyped, i.e. the dentry cache
> > separation and the slab helper for providing objects on the same page?
> >
> > [1] https://lwn.net/Articles/705758/
> 
> Hmmm. Sorry I am a bit late reading this I think. But I have a patchset
> that addresses some of these issues. See https://lwn.net/Articles/371892/

Yeah, this is the email thread I have referenced in my initial email. I
didn't reference the first email because Dave had some concerns about
your approach and then the discussion moved on to an approach which
sounds reasonable to me [2]

[2] https://lkml.org/lkml/2010/2/8/329

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
