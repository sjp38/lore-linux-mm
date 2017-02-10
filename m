Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id A38E06B0388
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 12:54:10 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id y196so57309453ity.1
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 09:54:10 -0800 (PST)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id 6si2650985ioj.112.2017.02.10.09.54.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Feb 2017 09:54:09 -0800 (PST)
Date: Fri, 10 Feb 2017 11:54:06 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] slab reclaim
In-Reply-To: <20170210145532.GQ10893@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1702101153010.29784@east.gentwo.org>
References: <20161228130949.GA11480@dhcp22.suse.cz> <20170102110257.GB18058@quack2.suse.cz> <b3e28101-1129-d2bc-8695-e7f7529a1442@suse.cz> <alpine.DEB.2.20.1701301243470.2833@east.gentwo.org> <20170210145532.GQ10893@dhcp22.suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Fri, 10 Feb 2017, Michal Hocko wrote:

> Yeah, this is the email thread I have referenced in my initial email. I
> didn't reference the first email because Dave had some concerns about
> your approach and then the discussion moved on to an approach which
> sounds reasonable to me [2]
>
> [2] https://lkml.org/lkml/2010/2/8/329

Dont see much there to go on aside from the statement of the problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
