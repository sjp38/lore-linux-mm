Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 8531D6B0038
	for <linux-mm@kvack.org>; Fri, 27 Nov 2015 02:56:55 -0500 (EST)
Received: by wmvv187 with SMTP id v187so58938335wmv.1
        for <linux-mm@kvack.org>; Thu, 26 Nov 2015 23:56:54 -0800 (PST)
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com. [74.125.82.46])
        by mx.google.com with ESMTPS id bt17si46390581wjb.137.2015.11.26.23.56.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Nov 2015 23:56:54 -0800 (PST)
Received: by wmvv187 with SMTP id v187so58937790wmv.1
        for <linux-mm@kvack.org>; Thu, 26 Nov 2015 23:56:53 -0800 (PST)
Date: Fri, 27 Nov 2015 08:56:52 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] jbd2: get rid of superfluous __GFP_REPEAT
Message-ID: <20151127075651.GB2493@dhcp22.suse.cz>
References: <1446740160-29094-4-git-send-email-mhocko@kernel.org>
 <1446826623-23959-1-git-send-email-mhocko@kernel.org>
 <563D526F.6030504@I-love.SAKURA.ne.jp>
 <20151108050802.GB3880@thunk.org>
 <20151109081650.GA8916@dhcp22.suse.cz>
 <20151126151017.GJ7953@dhcp22.suse.cz>
 <20151126201817.GC2632@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151126201817.GC2632@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, john.johansen@canonical.com

On Thu 26-11-15 15:18:17, Theodore Ts'o wrote:
> On Thu, Nov 26, 2015 at 04:10:17PM +0100, Michal Hocko wrote:
> > Hi Ted,
> > are there any objections for the patch or should I just repost it?
> 
> Sorry, when you first posted it I was crazy busy before going on a two
> week vacation/pilgrimage (and in fact I'm still in Jerusalem, but I'm
> going to be heading home soon).  I am starting to work on some
> patches, and expect to have time to do more work on the airplane.  The
> patches are queued up, and so I haven't lost them.  So feel free to
> repost them if you want, but it's not necessary unless you have some
> fixup to the patch.

Sure, no worry, this is nothing urgent, I just wanted to make sure it
doesn't fall thought the cracks. If you have the latest one I was
replying to then everything should be ok.

Thanks
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
