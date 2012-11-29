Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id DCFE36B0081
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 14:02:25 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC, PATCH 00/19] Numa aware LRU lists and shrinkers
References: <1354058086-27937-1-git-send-email-david@fromorbit.com>
Date: Thu, 29 Nov 2012 11:02:24 -0800
In-Reply-To: <1354058086-27937-1-git-send-email-david@fromorbit.com> (Dave
	Chinner's message of "Wed, 28 Nov 2012 10:14:27 +1100")
Message-ID: <m24nk8grlr.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: glommer@parallels.com, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com

Dave Chinner <david@fromorbit.com> writes:
>
> Comments, thoughts and flames all welcome.

Doing the reclaim per CPU sounds like a big change in the VM balance. 
Doesn't this invalidate some zone reclaim mode settings?
How did you validate all this?

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
