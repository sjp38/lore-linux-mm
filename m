Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 9B94C6B0253
	for <linux-mm@kvack.org>; Tue, 18 Aug 2015 06:36:38 -0400 (EDT)
Received: by wijp15 with SMTP id p15so96675977wij.0
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 03:36:38 -0700 (PDT)
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com. [209.85.212.172])
        by mx.google.com with ESMTPS id n3si26466736wiy.113.2015.08.18.03.36.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Aug 2015 03:36:36 -0700 (PDT)
Received: by wijp15 with SMTP id p15so96675577wij.0
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 03:36:36 -0700 (PDT)
Date: Tue, 18 Aug 2015 12:36:34 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 4/8] jbd, jbd2: Do not fail journal because of
 frozen_buffer allocation failure
Message-ID: <20150818103634.GB5033@dhcp22.suse.cz>
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

I haven't yet. I was waiting for more feedback and didn't want to spam
the mailing list too much. I will post them now.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
