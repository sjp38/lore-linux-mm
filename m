Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 629A06B0007
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 19:13:54 -0500 (EST)
Message-ID: <50F893D2.7080103@parallels.com>
Date: Thu, 17 Jan 2013 16:14:10 -0800
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 09/19] list_lru: per-node list infrastructure
References: <1354058086-27937-1-git-send-email-david@fromorbit.com> <1354058086-27937-10-git-send-email-david@fromorbit.com> <50F6FDC8.5020909@parallels.com> <20130116225521.GF2498@dastard> <50F7475F.90609@parallels.com> <20130117042245.GG2498@dastard> <50F84118.7030608@parallels.com> <20130118001029.GK2498@dastard>
In-Reply-To: <20130118001029.GK2498@dastard>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>, Suleiman Souhlal <suleiman@google.com>

On 01/17/2013 04:10 PM, Dave Chinner wrote:
> And then each object uses:
> 
> struct lru_item {
> 	struct list_head global_list;
> 	struct list_head memcg_list;
> }
by objects you mean dentries, inodes, and the such, right?
Would it be acceptable to you?

We've been of course doing our best to avoid increasing the size of the
objects, therefore this is something we've never mentioned. However, if
it would be acceptable from the fs POV, this would undoubtedly make our
life extremely easier.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
