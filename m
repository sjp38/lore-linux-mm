Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 7B7536B006A
	for <linux-mm@kvack.org>; Sun, 10 Oct 2010 11:56:47 -0400 (EDT)
Message-ID: <4CB1E22F.9060008@redhat.com>
Date: Sun, 10 Oct 2010 17:56:31 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 02/12] Halt vcpu if page it tries to access is swapped
 out.
References: <1286207794-16120-1-git-send-email-gleb@redhat.com> <1286207794-16120-3-git-send-email-gleb@redhat.com> <4CAD97D0.70100@redhat.com> <20101007174716.GD2397@redhat.com> <4CB0B4BA.5010901@redhat.com> <20101010072946.GJ2397@redhat.com> <4CB1E1ED.6050405@redhat.com>
In-Reply-To: <4CB1E1ED.6050405@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

  On 10/10/2010 05:55 PM, Avi Kivity wrote:
>> There is special completion that tells guest to wake all sleeping tasks
>> on vcpu. It is delivered after migration on the destination.
>>
> >
>
> Yes, I saw.
>
> What if you can't deliver it?  is it possible that some other vcpu 
> will start receiving apfs that alias the old ones?  Or is the 
> broadcast global?
>

And, is the broadcast used only for migrations?


-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
