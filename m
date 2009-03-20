Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0D9186B004F
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 11:38:33 -0400 (EDT)
Message-ID: <49C3B886.8080408@goop.org>
Date: Fri, 20 Mar 2009 08:38:46 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: Question about x86/mm/gup.c's use of disabled interrupts
References: <49C148AF.5050601@goop.org> <200903191232.05459.nickpiggin@yahoo.com.au> <49C2818B.9060201@goop.org> <20090320044029.GD6807@linux.vnet.ibm.com>
In-Reply-To: <20090320044029.GD6807@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: paulmck@linux.vnet.ibm.com
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Avi Kivity <avi@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Xen-devel <xen-devel@lists.xensource.com>, Jan Beulich <jbeulich@novell.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Paul E. McKenney wrote:
>> Ah, interesting.  So disabling interrupts prevents the RCU free from 
>> happening, and non-atomic pte fetching is a non-issue.  So it doesn't 
>> address the PAE side of the problem.
>>     
>
> This would be rcu_sched, correct?
>   

I guess?  Whatever it is that ends up calling all the rcu callbacks 
after the idle.  A cpu with disabled interrupts can't go through idle, 
right?  Or is there an explicit way to hold off rcu?

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
