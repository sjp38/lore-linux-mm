Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 449056B00C7
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 16:28:32 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id eu11so2077116pac.9
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 13:28:32 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id ih7si7033073pad.136.2014.11.06.13.28.28
        for <linux-mm@kvack.org>;
        Thu, 06 Nov 2014 13:28:29 -0800 (PST)
Date: Fri, 7 Nov 2014 08:28:14 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm: Fix comment before truncate_setsize()
Message-ID: <20141106212814.GH28565@dastard>
References: <1415206806-6173-1-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1415206806-6173-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jan Beulich <JBeulich@suse.com>

On Wed, Nov 05, 2014 at 06:00:06PM +0100, Jan Kara wrote:
> XFS doesn't always hold i_mutex when calling truncate_setsize() and it
> uses a different lock to serialize truncates and writes. So fix the
> comment before truncate_setsize().
> 
> Reported-by: Jan Beulich <JBeulich@suse.com>
> Signed-off-by: Jan Kara <jack@suse.cz>

I'll pull this into the xfs tree with the other fix. SHould go to
linus tomorrow morning now that I've got all the XFS issues that
were holding it up sorted out.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
