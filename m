Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id A3A2B6B0007
	for <linux-mm@kvack.org>; Fri, 18 Jan 2013 03:11:35 -0500 (EST)
Date: Fri, 18 Jan 2013 19:11:33 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 09/19] list_lru: per-node list infrastructure
Message-ID: <20130118081133.GQ2498@dastard>
References: <1354058086-27937-1-git-send-email-david@fromorbit.com>
 <1354058086-27937-10-git-send-email-david@fromorbit.com>
 <50F6FDC8.5020909@parallels.com>
 <20130116225521.GF2498@dastard>
 <50F7475F.90609@parallels.com>
 <20130117042245.GG2498@dastard>
 <50F84118.7030608@parallels.com>
 <20130118001029.GK2498@dastard>
 <50F893D2.7080103@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50F893D2.7080103@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>, Suleiman Souhlal <suleiman@google.com>

On Thu, Jan 17, 2013 at 04:14:10PM -0800, Glauber Costa wrote:
> On 01/17/2013 04:10 PM, Dave Chinner wrote:
> > And then each object uses:
> > 
> > struct lru_item {
> > 	struct list_head global_list;
> > 	struct list_head memcg_list;
> > }
> by objects you mean dentries, inodes, and the such, right?

Yup.

> Would it be acceptable to you?

If it works the way I think it should, then yes.

> We've been of course doing our best to avoid increasing the size of the
> objects, therefore this is something we've never mentioned. However, if
> it would be acceptable from the fs POV, this would undoubtedly make our
> life extremely easier.

I've been trying hard to work out how to avoid increasing the size
of structures as well. But if we can't work out how to implement
something sanely with only a single list head per object to work
from, then increasing the size of objects is something that we need
to consider if it solves all the problems we are trying to solve.

i.e. if adding a second list head makes the code dumb, simple,
obviously correct and hard to break then IMO it's a no-brainer.
But we have to tick all the right boxes first...

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
