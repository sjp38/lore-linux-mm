Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id AA3076B007E
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 15:48:37 -0500 (EST)
Message-ID: <4B0D97F9.70106@redhat.com>
Date: Wed, 25 Nov 2009 15:47:53 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] vmscan: do not evict inactive pages when skipping an
 active list scan
References: <20091125133752.2683c3e4@bree.surriel.com> <20091125203509.GA18018@cmpxchg.org>
In-Reply-To: <20091125203509.GA18018@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, lwoodman@redhat.com, kosaki.motohiro@fujitsu.co.jp, Tomasz Chmielewski <mangoo@wpkg.org>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On 11/25/2009 03:35 PM, Johannes Weiner wrote:
> Hello all,
>
> On Wed, Nov 25, 2009 at 01:37:52PM -0500, Rik van Riel wrote:
>    
>> In AIM7 runs, recent kernels start swapping out anonymous pages
>> well before they should.  This is due to shrink_list falling
>> through to shrink_inactive_list if !inactive_anon_is_low(zone, sc),
>> when all we really wanted to do is pre-age some anonymous pages to
>> give them extra time to be referenced while on the inactive list.
>>      
> I do not quite understand what changed 'recently'.
>
> That fall-through logic to keep eating inactives when the ratio is off
> came in a year ago with the second-chance-for-anon-pages patch..?
>
>    
The confusion comes from my use of the word
"recently" here.  Larry started testing with
RHEL 5 as the baseline.

And yeah - I believe the code may well have
been wrong ever since it was merged. The
indentation just looked so pretty that noone
spotted the bug.

> Acked-by: Johannes Weiner<hannes@cmpxchg.org>
>
>    
Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
