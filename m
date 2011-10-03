Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 481E39000F0
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 06:42:26 -0400 (EDT)
Message-ID: <4E899162.6040806@parallels.com>
Date: Mon, 3 Oct 2011 14:41:38 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 1/8] Basic kernel memory functionality for the Memory
 Controller
References: <1317637123-18306-1-git-send-email-glommer@parallels.com> <1317637123-18306-2-git-send-email-glommer@parallels.com> <20111003104133.GA29312@shutemov.name>
In-Reply-To: <20111003104133.GA29312@shutemov.name>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, avagin@parallels.com

On 10/03/2011 02:41 PM, Kirill A. Shutemov wrote:
> On Mon, Oct 03, 2011 at 02:18:36PM +0400, Glauber Costa wrote:
>> This patch lays down the foundation for the kernel memory component
>> of the Memory Controller.
>>
>> As of today, I am only laying down the following files:
>>
>>   * memory.independent_kmem_limit
>>   * memory.kmem.limit_in_bytes (currently ignored)
>>   * memory.kmem.usage_in_bytes (always zero)
>>
>> Signed-off-by: Glauber Costa<glommer@parallels.com>
>> CC: Paul Menage<paul@paulmenage.org>
>> CC: Greg Thelen<gthelen@google.com>
>
> Reviewed-by: Kirill A. Shutemov<kirill@shutemov.name>
>
> One comment bellow.
>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index ebd1e86..8aaf4ce 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -72,8 +72,6 @@ static int really_do_swap_account __initdata = 0;
>>   #else
>>   #define do_swap_account		(0)
>>   #endif
>> -
>> -
>>   /*
>>    * Statistics for memory cgroup.
>>    */
>
> Please drop this hunk.
>
Just did. Thanks for noticing, I missed this one.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
