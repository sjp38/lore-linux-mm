Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C666B6B0071
	for <linux-mm@kvack.org>; Sun, 20 Jun 2010 19:10:55 -0400 (EDT)
Date: Mon, 21 Jun 2010 09:10:17 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 0/3] writeback visibility
Message-ID: <20100620231017.GI6590@dastard>
References: <1276907415-504-1-git-send-email-mrubin@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1276907415-504-1-git-send-email-mrubin@google.com>
Sender: owner-linux-mm@kvack.org
To: Michael Rubin <mrubin@google.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, jack@suse.cz, akpm@linux-foundation.org, hch@lst.de, axboe@kernel.dk
List-ID: <linux-mm.kvack.org>

On Fri, Jun 18, 2010 at 05:30:12PM -0700, Michael Rubin wrote:
> Debugging writeback issues and tuning an application's writeback activity is
> easier when the activity is visible.  With large clusters, classifying
> and root causing writeback problems has been a big headache. This patch
> series contains a series of patches that our team has been using to start
> getting a handle on writeback behaviour. These changes should be helpful
> for single system maintainers also. It's still a big headache.
> 
> Once these changes are reviewed I will make sure the Documentation files
> are updated, but I expect some back and forth first.
> 
> Michael Rubin (3):
>   writeback: Creating /sys/kernel/mm/writeback/writeback
>   writeback: per bdi monitoring
>   writeback: tracking subsystems causing writeback

I'm not sure we want to export statistics that represent internal
implementation details into a fixed userspace API. Who, other than
developers, are going to understand and be able to make use of this
information?

FWIW, I've got to resend the writeback tracing patches to Jens that I
have that give better visibility into the writeback behaviour.
Perhaps those tracing events are a better basis for tracking down
writeback problems - the bugs I found with the tracing could not
have been found with these statistics...

That's really why I'm asking - if the stats are just there to help
development and debugging, then I think that improving the writeback
tracing is a better approach to improving visibility of writeback
behaviour...

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
