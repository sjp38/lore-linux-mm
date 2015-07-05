Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f170.google.com (mail-yk0-f170.google.com [209.85.160.170])
	by kanga.kvack.org (Postfix) with ESMTP id 7C283280246
	for <linux-mm@kvack.org>; Sun,  5 Jul 2015 17:06:04 -0400 (EDT)
Received: by ykdr198 with SMTP id r198so132759870ykd.3
        for <linux-mm@kvack.org>; Sun, 05 Jul 2015 14:06:04 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id o189si11183512ywb.71.2015.07.05.14.06.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 Jul 2015 14:06:03 -0700 (PDT)
Date: Sun, 5 Jul 2015 17:06:00 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH] ext4: replace open coded nofail allocation
Message-ID: <20150705210600.GD8628@thunk.org>
References: <1435053037-1451-1-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1435053037-1451-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, Jun 23, 2015 at 11:50:37AM +0200, Michal Hocko wrote:
> ext4_free_blocks is looping around the allocation request and mimics
> __GFP_NOFAIL behavior without any allocation fallback strategy. Let's
> remove the open coded loop and replace it with __GFP_NOFAIL. Without
> the flag the allocator has no way to find out never-fail requirement
> and cannot help in any way.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Thanks, applied.

					- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
