Message-ID: <3D9DF64A.4050405@us.ibm.com>
Date: Fri, 04 Oct 2002 13:12:58 -0700
From: Dave Hansen <haveblue@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH]  4KB stack + irq stack for x86
References: <3D9DF34D.2030405@us.ibm.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Benjamin LaHaise <bcrl@redhat.com>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> I fixed the problems that I was having.  thread_info->preempt_count is 
> now used to store softirq state, unlike in 2.5.20.  Preempt count was 
> not preserved once the switch to the interrupt stack occurred.  This 
> caused two nested softirqs and a deadlock.  It is fixed now.

That'll teach me to get excited and send a patch.  Sorry about the 
"Only in"'s.  I also think that there is still a small race window in 
the code that I sent.  I think that the old preempt_count need to be 
placed into the new thread_info's preempt_count _before_ the stack 
switch occurs.

-- 
Dave Hansen
haveblue@us.ibm.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
