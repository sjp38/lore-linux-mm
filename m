Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 39514600309
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 06:03:29 -0500 (EST)
Message-ID: <4B13A5FC.10605@redhat.com>
Date: Mon, 30 Nov 2009 13:01:16 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 10/12] Maintain preemptability count even for !CONFIG_PREEMPT
 kernels
References: <1258985167-29178-1-git-send-email-gleb@redhat.com>	 <1258985167-29178-11-git-send-email-gleb@redhat.com>	 <1258990455.4531.594.camel@laptop> <20091123155851.GU2999@redhat.com>	 <alpine.DEB.2.00.0911231128190.785@router.home>	 <20091124071250.GC2999@redhat.com>	 <alpine.DEB.2.00.0911240906360.14045@router.home>	 <20091130105612.GF30150@redhat.com>  <20091130105812.GG30150@redhat.com> <1259578793.20516.130.camel@laptop>
In-Reply-To: <1259578793.20516.130.camel@laptop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Gleb Natapov <gleb@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On 11/30/2009 12:59 PM, Peter Zijlstra wrote:
>> Forgot to tell. The results are average between 5 different runs.
>>      
> Would be good to also report the variance over those 5 runs, allows us
> to see if the difference is within the noise.
>    

That's the stddev column.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
