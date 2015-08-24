Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 4FC166B0038
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 08:06:08 -0400 (EDT)
Received: by wijp15 with SMTP id p15so75590192wij.0
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 05:06:07 -0700 (PDT)
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com. [209.85.212.176])
        by mx.google.com with ESMTPS id lr7si31682142wjb.35.2015.08.24.05.06.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Aug 2015 05:06:06 -0700 (PDT)
Received: by wicne3 with SMTP id ne3so70083626wic.0
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 05:06:06 -0700 (PDT)
Date: Mon, 24 Aug 2015 14:06:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 4/8] jbd, jbd2: Do not fail journal because of
 frozen_buffer allocation failure
Message-ID: <20150824120604.GM17078@dhcp22.suse.cz>
References: <1438768284-30927-1-git-send-email-mhocko@kernel.org>
 <1438768284-30927-5-git-send-email-mhocko@kernel.org>
 <xr93twsdwui3.fsf@gthelen.mtv.corp.google.com>
 <20150812091411.GB14940@dhcp22.suse.cz>
 <20150815135422.GA2976@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150815135422.GA2976@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Greg Thelen <gthelen@google.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Dave Chinner <david@fromorbit.com>, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, Jan Kara <jack@suse.cz>

Hi Ted,

On Sat 15-08-15 09:54:22, Theodore Ts'o wrote:
> On Wed, Aug 12, 2015 at 11:14:11AM +0200, Michal Hocko wrote:
> > > Is this "if (!committed_data) {" check now dead code?
> > > 
> > > I also see other similar suspected dead sites in the rest of the series.
> > 
> > You are absolutely right. I have updated the patches.
> 
> Have you sent out an updated version of these patches?  Maybe I missed
> it, but I don't think I saw them.

would you be interested in these two patches sent with rephrased
changelog to not depend on the patch which allows GFP_NOFS to fail? The
way this has been handled for btrfs...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
