Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0C4EF8D0017
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 09:48:56 -0500 (EST)
Message-ID: <4CE14848.2060805@redhat.com>
Date: Mon, 15 Nov 2010 09:48:40 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: fadvise DONTNEED implementation (or lack thereof)
References: <20101109162525.BC87.A69D9226@jp.fujitsu.com>	<877hgmr72o.fsf@gmail.com>	<20101114140920.E013.A69D9226@jp.fujitsu.com>	<AANLkTim59Qx6TsvXnTBL5Lg6JorbGaqx3KsdBDWO04X9@mail.gmail.com>	<1289810825.2109.469.camel@laptop> <AANLkTikibS1fDuk67RHk4SU14pJ9nPdodWba1T3Z_pWE@mail.gmail.com>
In-Reply-To: <AANLkTikibS1fDuk67RHk4SU14pJ9nPdodWba1T3Z_pWE@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Ben Gamari <bgamari.foss@gmail.com>, linux-kernel@vger.kernel.org, rsync@lists.samba.org, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On 11/15/2010 04:05 AM, Minchan Kim wrote:
> On Mon, Nov 15, 2010 at 5:47 PM, Peter Zijlstra<peterz@infradead.org>  wrote:
>> On Mon, 2010-11-15 at 15:07 +0900, Minchan Kim wrote:

>>> I wonder what's the problem in Peter's patch 'drop behind'.
>>> http://www.mail-archive.com/linux-kernel@vger.kernel.org/msg179576.html
>>>
>>> Could anyone tell me why it can't accept upstream?
>>
>> Read the thread, its quite clear nobody got convinced it was a good idea
>> and wanted to fix the use-once policy, then Rik rewrote all of
>> page-reclaim.
>>
>
> Thanks for the information.
> I hope this is a chance to rethink about it.
> Rik, Could you give us to any comment about this idea?

At the time, there were all kinds of general problems
in page reclaim that all needed to be fixed.  Peter's
patch was mostly a band-aid for streaming IO.

However, now that most of the other page reclaim problems
seem to have been resolved, it would be worthwhile to test
whether Peter's drop-behind approach gives an additional
improvement.

I could see it help by getting rid of already-read pages
earlier, leaving more space for read-ahead data.

I suspect it would do fairly little to protect the working
set, because we do not scan the active file list at all
unless it grows to be larger than the inactive file list.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
