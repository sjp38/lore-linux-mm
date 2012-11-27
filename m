Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 31BCB6B004D
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 16:25:15 -0500 (EST)
Date: 27 Nov 2012 16:25:14 -0500
Message-ID: <20121127212514.1173.qmail@science.horizon.com>
From: "George Spelvin" <linux@horizon.com>
Subject: Re: 3.7-rc6 soft lockup in kswapd0
In-Reply-To: <20121126190926.GM8218@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux@horizon.com, mgorman@suse.de
Cc: dave@linux.vnet.ibm.com, hannes@cmpxchg.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com

Mel Gorman <mgorman@suse.de> wrote:
> On Mon, Nov 26, 2012 at 01:53:17PM -0500, George Spelvin wrote:
>> Johannes Weiner <hannes@cmpxchg.org> wrote:
>>> Any chance you could test with this fix instead, in addition to Dave's
>>> accounting fix?  It's got bool and everything!
> 
>> Okay.  Mel, speak up if you object.  I also rebased on top of 3.7-rc7,
>> which already includes Dave's fix.  Again, speak up if that's a bad idea.
> 
> No objections all round.

Well, it just made it to 24 hours, 
it did before.  I'm going to wait a couple more days before declaring
victory, but it looks good so far.

 19:19:10 up 1 day, 0 min,  2 users,  load average: 0.15, 0.20, 0.22
 21:24:05 up 1 day,  2:05,  2 users,  load average: 0.25, 0.19, 0.18

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
