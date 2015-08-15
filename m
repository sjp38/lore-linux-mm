Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f175.google.com (mail-yk0-f175.google.com [209.85.160.175])
	by kanga.kvack.org (Postfix) with ESMTP id 44AAC6B0038
	for <linux-mm@kvack.org>; Sat, 15 Aug 2015 09:54:30 -0400 (EDT)
Received: by ykfw73 with SMTP id w73so37398272ykf.3
        for <linux-mm@kvack.org>; Sat, 15 Aug 2015 06:54:30 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id d128si5417162ywf.82.2015.08.15.06.54.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Aug 2015 06:54:29 -0700 (PDT)
Date: Sat, 15 Aug 2015 09:54:22 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [RFC 4/8] jbd, jbd2: Do not fail journal because of
 frozen_buffer allocation failure
Message-ID: <20150815135422.GA2976@thunk.org>
References: <1438768284-30927-1-git-send-email-mhocko@kernel.org>
 <1438768284-30927-5-git-send-email-mhocko@kernel.org>
 <xr93twsdwui3.fsf@gthelen.mtv.corp.google.com>
 <20150812091411.GB14940@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150812091411.GB14940@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Greg Thelen <gthelen@google.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Dave Chinner <david@fromorbit.com>, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, Jan Kara <jack@suse.cz>

On Wed, Aug 12, 2015 at 11:14:11AM +0200, Michal Hocko wrote:
> > Is this "if (!committed_data) {" check now dead code?
> > 
> > I also see other similar suspected dead sites in the rest of the series.
> 
> You are absolutely right. I have updated the patches.

Have you sent out an updated version of these patches?  Maybe I missed
it, but I don't think I saw them.

Thanks,

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
