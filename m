Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id D68256B0003
	for <linux-mm@kvack.org>; Tue,  5 Jun 2018 17:38:48 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id c6-v6so2047573pll.4
        for <linux-mm@kvack.org>; Tue, 05 Jun 2018 14:38:48 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j6-v6si9970614pll.54.2018.06.05.14.38.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jun 2018 14:38:47 -0700 (PDT)
Date: Tue, 5 Jun 2018 14:38:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 199931] New: systemd/rtorrent file data corruption when
 using echo 3 >/proc/sys/vm/drop_caches
Message-Id: <20180605143846.ec86323745ead25c74bc4c37@linux-foundation.org>
In-Reply-To: <34c7a73b-15d5-4d67-fa7c-0630b30a4c1c@i-love.sakura.ne.jp>
References: <bug-199931-27@https.bugzilla.kernel.org/>
	<20180605130329.f7069e01c5faacc08a10996c@linux-foundation.org>
	<34c7a73b-15d5-4d67-fa7c-0630b30a4c1c@i-love.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Chris Mason <clm@fb.com>, Michal Hocko <mhocko@suse.com>, bugzilla-daemon@bugzilla.kernel.org, bugzilla.kernel.org@plan9.de, linux-btrfs@vger.kernel.org, linux-mm@kvack.org, Jan Kara <jack@suse.cz>

On Wed, 6 Jun 2018 06:22:25 +0900 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp> wrote:

> On 2018/06/06 5:03, Andrew Morton wrote:
> > 
> > (switched to email.  Please respond via emailed reply-to-all, not via the
> > bugzilla web interface).
> > 
> > On Tue, 05 Jun 2018 18:01:36 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:
> > 
> >> https://bugzilla.kernel.org/show_bug.cgi?id=199931
> >>
> >>             Bug ID: 199931
> >>            Summary: systemd/rtorrent file data corruption when using echo
> >>                     3 >/proc/sys/vm/drop_caches
> > 
> > A long tale of woe here.  Chris, do you think the pagecache corruption
> > is a general thing, or is it possible that btrfs is contributing?
> 
> According to timestamp of my testcases, I was observing corrupted-bytes issue upon OOM-kill
> (without using btrfs) as of 2017 Aug 11. Thus, I don't think that this is specific to btrfs.
> But I can't find which patch fixed this issue.

That sounds different.  Here, the corruption is caused by performing
drop_caches, not by an oom-killing.
