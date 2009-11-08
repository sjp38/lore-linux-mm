Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 0E7946B007B
	for <linux-mm@kvack.org>; Sun,  8 Nov 2009 08:09:09 -0500 (EST)
Message-ID: <4AF6C2E7.8040107@redhat.com>
Date: Sun, 08 Nov 2009 15:08:55 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/11] Add "handle page fault" PV helper.
References: <20091102092214.GB8933@elte.hu> <20091102160410.GF27911@redhat.com> <20091102161248.GB15423@elte.hu> <20091102162234.GH27911@redhat.com> <20091102162941.GC14544@elte.hu> <20091102174208.GJ27911@redhat.com> <20091108113654.GO11372@elte.hu> <4AF6BCE5.3030701@redhat.com> <20091108125135.GA13099@elte.hu> <4AF6C112.4010601@redhat.com> <20091108130521.GA29728@elte.hu>
In-Reply-To: <20091108130521.GA29728@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Gleb Natapov <gleb@redhat.com>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Fr??d??ric Weisbecker <fweisbec@gmail.com>
List-ID: <linux-mm.kvack.org>

On 11/08/2009 03:05 PM, Ingo Molnar wrote:
>> We can take the "immediate values" infrastructure as a first step. Has
>> that been merged?
>>      
> No, there were doubts about whether patching in live instructions like
> that is safe on all CPU types.
>    

Ah, I remember.  Doesn't the trick of going through a breakpoint 
instruction work?

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
