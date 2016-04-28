Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id CCD3A6B007E
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 04:18:02 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id j8so57236088lfd.0
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 01:18:02 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id r68si11942003wmg.2.2016.04.28.01.18.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Apr 2016 01:18:01 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id r12so20673840wme.0
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 01:18:01 -0700 (PDT)
Date: Thu, 28 Apr 2016 10:17:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm, debug: report when GFP_NO{FS,IO} is used
 explicitly from memalloc_no{fs,io}_{save,restore} context
Message-ID: <20160428081759.GA31489@dhcp22.suse.cz>
References: <1461671772-1269-1-git-send-email-mhocko@kernel.org>
 <1461671772-1269-3-git-send-email-mhocko@kernel.org>
 <20160426225845.GF26977@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160426225845.GF26977@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, xfs@oss.sgi.com, LKML <linux-kernel@vger.kernel.org>

[Trim the CC list]
On Wed 27-04-16 08:58:45, Dave Chinner wrote:
[...]
> Often these are to silence lockdep warnings (e.g. commit b17cb36
> ("xfs: fix missing KM_NOFS tags to keep lockdep happy")) because
> lockdep gets very unhappy about the same functions being called with
> different reclaim contexts. e.g.  directory block mapping might
> occur from readdir (no transaction context) or within transactions
> (create/unlink). hence paths like this are tagged with GFP_NOFS to
> stop lockdep emitting false positive warnings....

As already said in other email, I have tried to revert the above
commit and tried to run it with some fs workloads but didn't manage
to hit any lockdep splats (after I fixed my bug in the patch 1.2). I
have tried to find reports which led to this commit but didn't succeed
much. Everything is from much earlier or later. Do you happen to
remember which loads triggered them, what they looked like or have an
idea what to try to reproduce them? So far I was trying heavy parallel
fs_mark, kernbench inside a tiny virtual machine so any of those have
triggered direct reclaim all the time.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
