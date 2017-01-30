Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id BB5B66B0038
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 13:47:08 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id y196so159484545ity.1
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 10:47:08 -0800 (PST)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id g140si11381909iog.117.2017.01.30.10.47.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jan 2017 10:47:08 -0800 (PST)
Date: Mon, 30 Jan 2017 12:47:04 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] slab reclaim
In-Reply-To: <b3e28101-1129-d2bc-8695-e7f7529a1442@suse.cz>
Message-ID: <alpine.DEB.2.20.1701301243470.2833@east.gentwo.org>
References: <20161228130949.GA11480@dhcp22.suse.cz> <20170102110257.GB18058@quack2.suse.cz> <b3e28101-1129-d2bc-8695-e7f7529a1442@suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@kernel.org>, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Thu, 5 Jan 2017, Vlastimil Babka wrote:

>
> Yeah, some of the related stuff that was discussed at Kernel Summit [1]
> would be nice to have at least prototyped, i.e. the dentry cache
> separation and the slab helper for providing objects on the same page?
>
> [1] https://lwn.net/Articles/705758/

Hmmm. Sorry I am a bit late reading this I think. But I have a patchset
that addresses some of these issues. See https://lwn.net/Articles/371892/
Would like to rework some of that for the current kernel sources. Matthew
Wilcox told me that he may be able top use this to implement
reclaim/defrag in the radix tree code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
