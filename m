Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 026458D0039
	for <linux-mm@kvack.org>; Sat,  5 Feb 2011 13:05:50 -0500 (EST)
Message-ID: <4D4D911A.5080001@oracle.com>
Date: Sat, 05 Feb 2011 10:04:10 -0800
From: Randy Dunlap <randy.dunlap@oracle.com>
MIME-Version: 1.0
Subject: Re: [patch fixup] memcg: remove direct page_cgroup-to-page pointer
 fix
References: <201102042349.p14NnQEm025834@imap1.linux-foundation.org> <20110204183810.76baf8f0.randy.dunlap@oracle.com> <20110205090451.GA2315@cmpxchg.org>
In-Reply-To: <20110205090451.GA2315@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On 02/05/11 01:04, Johannes Weiner wrote:
> On Fri, Feb 04, 2011 at 06:38:10PM -0800, Randy Dunlap wrote:
>> On Fri, 04 Feb 2011 15:15:17 -0800 akpm@linux-foundation.org wrote:
>>
>>> The mm-of-the-moment snapshot 2011-02-04-15-15 has been uploaded to
>>>
>>>    http://userweb.kernel.org/~akpm/mmotm/
>>>
>>> and will soon be available at
>>>
>>>    git://zen-kernel.org/kernel/mmotm.git
>>>
>>> It contains the following patches against 2.6.38-rc3:
>>
>>
>> Lots of these warnings in some kernel configs:
>>
>> mmotm-2011-0204-1515/include/linux/page_cgroup.h:144: warning: left shift count >= width of type
>> mmotm-2011-0204-1515/include/linux/page_cgroup.h:145: warning: left shift count >= width of type
>> mmotm-2011-0204-1515/include/linux/page_cgroup.h:150: warning: right shift count >= width of type
> 
> Thanks for the report, Randy, and sorry for the breakage.  Here is the
> fixup:
> 
> ---
> Since the non-flags field for pc array ids in pc->flags is offset from
> the end of the word, we end up with a shift count of BITS_PER_LONG in
> case the field width is zero.
> 
> This results in a compiler warning as we shift in both directions a
> long int by BITS_PER_LONG.
> 
> There is no real harm -- the mask is zero -- but fix up the compiler
> warning by also making the shift count zero for a non-existant field.
> 
> Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---

Acked-by: Randy Dunlap <randy.dunlap@oracle.com>

Thanks.

-- 
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
