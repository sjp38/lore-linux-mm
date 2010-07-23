Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id ECDE86B024D
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 12:09:31 -0400 (EDT)
Date: Sat, 24 Jul 2010 02:09:25 +1000
From: Nick Piggin <npiggin@kernel.dk>
Subject: Re: [PATCH 0/2] vfs scalability tree fixes
Message-ID: <20100723160925.GA6316@amd>
References: <20100723111310.GI32635@dastard>
 <1279893842-4246-1-git-send-email-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1279893842-4246-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: npiggin@kernel.dk, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fmayhar@google.com, johnstul@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Sat, Jul 24, 2010 at 12:04:00AM +1000, Dave Chinner wrote:
> Nick,
> 
> Here's the fixes I applied to your tree to make the XFS inode cache
> shrinker build and scan sanely.

Thanks for these Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
