Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 640D96B026C
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 10:58:21 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id o3so36388959wjo.1
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 07:58:21 -0800 (PST)
Received: from mail-wj0-f194.google.com (mail-wj0-f194.google.com. [209.85.210.194])
        by mx.google.com with ESMTPS id b3si3882694wmd.58.2016.12.16.07.58.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 07:58:20 -0800 (PST)
Received: by mail-wj0-f194.google.com with SMTP id kp2so15201626wjc.0
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 07:58:20 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: OOM: Better, but still there on
Date: Fri, 16 Dec 2016 16:58:06 +0100
Message-Id: <20161216155808.12809-1-mhocko@kernel.org>
In-Reply-To: <20161216073941.GA26976@dhcp22.suse.cz>
References: <20161216073941.GA26976@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nils Holland <nholland@tisys.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org

On Fri 16-12-16 08:39:41, Michal Hocko wrote:
[...]
> That being said, the OOM killer invocation is clearly pointless and
> pre-mature. We normally do not invoke it normally for GFP_NOFS requests
> exactly for these reasons. But this is GFP_NOFS|__GFP_NOFAIL which
> behaves differently. I am about to change that but my last attempt [1]
> has to be rethought.
> 
> Now another thing is that the __GFP_NOFAIL which has this nasty side
> effect has been introduced by me d1b5c5671d01 ("btrfs: Prevent from
> early transaction abort") in 4.3 so I am quite surprised that this has
> shown up only in 4.8. Anyway there might be some other changes in the
> btrfs which could make it more subtle.
> 
> I believe the right way to go around this is to pursue what I've started
> in [1]. I will try to prepare something for testing today for you. Stay
> tuned. But I would be really happy if somebody from the btrfs camp could
> check the NOFS aspect of this allocation. We have already seen
> allocation stalls from this path quite recently

Could you try to run with the two following patches?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
