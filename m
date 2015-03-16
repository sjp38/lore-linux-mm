Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id D12C36B0038
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 03:46:13 -0400 (EDT)
Received: by wgdm6 with SMTP id m6so32586267wgd.2
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 00:46:13 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z10si16231618wiw.120.2015.03.16.00.46.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 16 Mar 2015 00:46:11 -0700 (PDT)
Date: Mon, 16 Mar 2015 08:46:07 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH 1/2 v2] mm: Allow small allocations to fail
Message-ID: <20150316074607.GA24885@dhcp22.suse.cz>
References: <1426107294-21551-1-git-send-email-mhocko@suse.cz>
 <1426107294-21551-2-git-send-email-mhocko@suse.cz>
 <201503151443.CFE04129.MVFOOStLFHFOQJ@I-love.SAKURA.ne.jp>
 <20150315121317.GA30685@dhcp22.suse.cz>
 <201503152206.AGJ22930.HOStFFFQLVMOOJ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201503152206.AGJ22930.HOStFFFQLVMOOJ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, david@fromorbit.com, mgorman@suse.de, riel@redhat.com, fengguang.wu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun 15-03-15 22:06:54, Tetsuo Handa wrote:
> Michal Hocko wrote:
[...]
> > this. I understand that the wording of the changelog might be confusing,
> > though.
> > 
> > It says: "This implementation counts only those retries which involved
> > OOM killer because we do not want to be too eager to fail the request."
> > 
> > Would it be more clear if I changed that to?
> > "This implemetnation counts only those retries when the system is
> > considered OOM because all previous reclaim attempts have resulted
> > in no progress because we do not want to be too eager to fail the
> > request."
> > 
> > We definitely _want_ to fail GFP_NOFS allocations.
> 
> I see. The updated changelog is much more clear.

Patch with the updated changelog (no other changes)
---
