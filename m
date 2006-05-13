Message-ID: <446538C0.6000004@yahoo.com.au>
Date: Sat, 13 May 2006 11:39:12 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] Zone boundry alignment fixes
References: <445DF3AB.9000009@yahoo.com.au> <exportbomb.1147172704@pinky> <20060511005952.3d23897c.akpm@osdl.org> <20060512141921.GA564@elte.hu>
In-Reply-To: <20060512141921.GA564@elte.hu>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@osdl.org>, Andy Whitcroft <apw@shadowen.org>, haveblue@us.ibm.com, bob.picco@hp.com, mbligh@mbligh.org, ak@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> * Andrew Morton <akpm@osdl.org> wrote:
> 
> 
>>There's some possibility here of interaction with Mel's "patchset to 
>>size zones and memory holes in an architecture-independent manner." I 
>>jammed them together - let's see how it goes.
> 
> 
> update: Andy's 3 patches, applied to 2.6.17-rc3-mm1, fixed all the 
> crashes and asserts i saw. NUMA-on-x86 is now rock-solid on my testbox. 
> Great work Andy!

Excellent. I think these should get into 2.6.17, and possibly even the
-stable series.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
