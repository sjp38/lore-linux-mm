Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f171.google.com (mail-yk0-f171.google.com [209.85.160.171])
	by kanga.kvack.org (Postfix) with ESMTP id 655DA6B0032
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 10:54:35 -0400 (EDT)
Received: by yked142 with SMTP id d142so53095231yke.3
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 07:54:35 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id 17si1267020ykz.152.2015.06.08.07.54.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 07:54:34 -0700 (PDT)
Date: Mon, 8 Jun 2015 10:54:32 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH -resend] jbd2: revert must-not-fail allocation loops back
 to GFP_NOFAIL
Message-ID: <20150608145432.GB19168@thunk.org>
References: <1433770124-19614-1-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1433770124-19614-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-ext4@vger.kernel.org, David Rientjes <rientjes@google.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, Jun 08, 2015 at 03:28:44PM +0200, Michal Hocko wrote:
> This basically reverts 47def82672b3 (jbd2: Remove __GFP_NOFAIL from jbd2
> layer). The deprecation of __GFP_NOFAIL was a bad choice because it led
> to open coding the endless loop around the allocator rather than
> removing the dependency on the non failing allocation. So the
> deprecation was a clear failure and the reality tells us that
> __GFP_NOFAIL is not even close to go away.
> 
> It is still true that __GFP_NOFAIL allocations are generally discouraged
> and new uses should be evaluated and an alternative (pre-allocations or
> reservations) should be considered but it doesn't make any sense to lie
> the allocator about the requirements. Allocator can take steps to help
> making a progress if it knows the requirements.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> Acked-by: David Rientjes <rientjes@google.com>

Applied, thanks.

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
