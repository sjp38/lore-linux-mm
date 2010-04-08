Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D4273600337
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 12:15:56 -0400 (EDT)
Message-ID: <4BBE01CB.9020701@humyo.com>
Date: Thu, 08 Apr 2010 17:18:19 +0100
From: John Berthels <john@humyo.com>
MIME-Version: 1.0
Subject: Re: PROBLEM + POSS FIX: kernel stack overflow, xfs, many disks, heavy
 write load, 8k stack, x86-64
References: <4BBC6719.7080304@humyo.com> <20100407140523.GJ11036@dastard> <4BBCAB57.3000106@humyo.com> <20100407234341.GK11036@dastard> <20100408030347.GM11036@dastard> <4BBDC92D.8060503@humyo.com> <4BBDEC9A.9070903@humyo.com>
In-Reply-To: <4BBDEC9A.9070903@humyo.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: linux-kernel@vger.kernel.org, Nick Gregory <nick@humyo.com>, Rob Sanderson <rob@humyo.com>, xfs@oss.sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

John Berthels wrote:
> John Berthels wrote:
>> I'll reply again after it's been running long enough to draw 
>> conclusions.
The box with patch+THREAD_ORDER 1+LOCKDEP went down (with no further 
logging retrievable by /var/log/messages or netconsole).

We're loading up a 2.6.33.2 + patch + THREAD_ORDER 2 (no LOCKDEP) to get 
better info as to whether we are still blowing the 8k limit with the 
patch in place.

jb

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
