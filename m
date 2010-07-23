Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 59DCB6B02A4
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 10:04:27 -0400 (EDT)
From: Dave Chinner <david@fromorbit.com>
Subject: [PATCH 0/2] vfs scalability tree fixes
Date: Sat, 24 Jul 2010 00:04:00 +1000
Message-Id: <1279893842-4246-1-git-send-email-david@fromorbit.com>
In-Reply-To: <20100723111310.GI32635@dastard>
References: <20100723111310.GI32635@dastard>
Sender: owner-linux-mm@kvack.org
To: npiggin@kernel.dk
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fmayhar@google.com, johnstul@us.ibm.com
List-ID: <linux-mm.kvack.org>

Nick,

Here's the fixes I applied to your tree to make the XFS inode cache
shrinker build and scan sanely.

Cheers,

Dave.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
