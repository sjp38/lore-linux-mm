Message-ID: <491A0BE5.1050407@redhat.com>
Date: Wed, 12 Nov 2008 00:49:09 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] add ksm kernel shared memory driver
References: <1226409701-14831-1-git-send-email-ieidus@redhat.com>	<1226409701-14831-2-git-send-email-ieidus@redhat.com>	<1226409701-14831-3-git-send-email-ieidus@redhat.com>	<1226409701-14831-4-git-send-email-ieidus@redhat.com> <20081111150345.7fff8ff2@bike.lwn.net> <491A0483.3010504@redhat.com>
In-Reply-To: <491A0483.3010504@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Izik Eidus <ieidus@redhat.com>
Cc: Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, aarcange@redhat.com, chrisw@redhat.com
List-ID: <linux-mm.kvack.org>

Izik Eidus wrote:
>> Any benchmarks on the runtime cost of having KSM running?
>>   
>
> This one is problematic, ksm can take anything from 0% to 100% cpu
> its all depend on how fast you run it.
> it have 3 parameters:
> number of pages to scan before it go to sleep
> maximum number of pages to merge while we scanning the above pages 
> (merging is expensive)
> time to sleep (when runing from userspace using /dev/ksm, we actually 
> do it there (userspace)

The scan process priority also has its effect.  One strategy would be to 
run it at idle priority as long as you have enough free memory, and 
increase the priority as memory starts depleting.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
