Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 242136B0253
	for <linux-mm@kvack.org>; Tue, 18 Aug 2015 13:12:03 -0400 (EDT)
Received: by qgj62 with SMTP id 62so122293751qgj.2
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 10:12:03 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id g2si32206420qhc.60.2015.08.18.10.12.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 18 Aug 2015 10:12:02 -0700 (PDT)
Date: Tue, 18 Aug 2015 13:11:44 -0400
From: Chris Mason <clm@fb.com>
Subject: Re: [RFC -v2 7/8] btrfs: Prevent from early transaction abort
Message-ID: <20150818171144.GA5206@ret.DHCP.TheFacebook.com>
References: <1438768284-30927-1-git-send-email-mhocko@kernel.org>
 <1438768284-30927-8-git-send-email-mhocko@kernel.org>
 <20150818104031.GF5033@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150818104031.GF5033@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, Jan Kara <jack@suse.cz>

On Tue, Aug 18, 2015 at 12:40:32PM +0200, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Btrfs relies on GFP_NOFS allocation when commiting the transaction but
> since "mm: page_alloc: do not lock up GFP_NOFS allocations upon OOM"
> those allocations are allowed to fail which can lead to a pre-mature
> transaction abort:

I can either put the btrfs nofail ones on my pull for Linus, or you can
add my sob and send as one unit.  Just let me know how you'd rather do
it.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
