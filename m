Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 2F6E090010C
	for <linux-mm@kvack.org>; Fri, 13 May 2011 07:03:01 -0400 (EDT)
Received: by wwi36 with SMTP id 36so2353909wwi.26
        for <linux-mm@kvack.org>; Fri, 13 May 2011 04:02:58 -0700 (PDT)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 3/3] checkpatch.pl: Add check for current->comm references
References: <1305241371-25276-1-git-send-email-john.stultz@linaro.org>
 <1305241371-25276-4-git-send-email-john.stultz@linaro.org>
 <4DCCD0C3.9090908@gmail.com>
Date: Fri, 13 May 2011 13:02:56 +0200
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.vve2a6hp3l0zgt@mnazarewicz-glaptop>
In-Reply-To: <4DCCD0C3.9090908@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>, Jiri Slaby <jirislaby@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Ted Ts'o <tytso@mit.edu>, KOSAKI
 Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew
 Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

> On 05/13/2011 01:02 AM, John Stultz wrote:
>> @@ -2868,6 +2868,10 @@ sub process {
>>  			WARN("usage of NR_CPUS is often wrong - consider using  
>> cpu_possible(), num_possible_cpus(), for_each_possible_cpu(), etc\n" .  
>> $herecurr);
>>  		}
>>
>> +# check for current->comm usage
>> +		if ($line =~ /current->comm/) {

On Fri, 13 May 2011 08:33:39 +0200, Jiri Slaby wrote:
> This should be something like \b(current|task|tsk|t)->comm\b to catch
> also non-current comm accesses...

Or \b(?:current|task|tsk|t)\s*->\s*comm\b.

>> +			WARN("comm access needs to be protected. Use get_task_comm, or  
>> printk's \%ptc formatting.\n" . $herecurr);
>> +		}

-- 
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=./ `o
..o | Computer Science,  Michal "mina86" Nazarewicz    (o o)
ooo +-----<email/xmpp: mnazarewicz@google.com>-----ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
