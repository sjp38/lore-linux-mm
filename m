Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id C637F6B0038
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 16:01:03 -0500 (EST)
Received: by mail-we0-f177.google.com with SMTP id q59so16937476wes.8
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 13:01:03 -0800 (PST)
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com. [195.75.94.107])
        by mx.google.com with ESMTPS id s5si4917564wju.40.2015.01.15.13.01.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 15 Jan 2015 13:01:02 -0800 (PST)
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Thu, 15 Jan 2015 21:01:02 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id E1A2A2190046
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 21:00:27 +0000 (GMT)
Received: from d06av06.portsmouth.uk.ibm.com (d06av06.portsmouth.uk.ibm.com [9.149.37.217])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t0FL10hh57540642
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 21:01:00 GMT
Received: from d06av06.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av06.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t0FFv7Ow002052
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 10:57:07 -0500
Message-ID: <54B82A8B.7000809@de.ibm.com>
Date: Thu, 15 Jan 2015 22:00:59 +0100
From: Christian Borntraeger <borntraeger@de.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/8] x86/spinlock: Leftover conversion ACCESS_ONCE->READ_ONCE
References: <1421312314-72330-1-git-send-email-borntraeger@de.ibm.com> <1421312314-72330-5-git-send-email-borntraeger@de.ibm.com> <20150115193839.GA28727@redhat.com> <54B81A37.80109@de.ibm.com> <20150115200119.GA29684@redhat.com>
In-Reply-To: <20150115200119.GA29684@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, xen-devel@lists.xenproject.org, linux-mm@kvack.org

Am 15.01.2015 um 21:01 schrieb Oleg Nesterov:
> On 01/15, Christian Borntraeger wrote:
>>
>> Am 15.01.2015 um 20:38 schrieb Oleg Nesterov:
>>> On 01/15, Christian Borntraeger wrote:
>>>>
>>>> --- a/arch/x86/include/asm/spinlock.h
>>>> +++ b/arch/x86/include/asm/spinlock.h
>>>> @@ -186,7 +186,7 @@ static inline void arch_spin_unlock_wait(arch_spinlock_t *lock)
>>>>  	__ticket_t head = ACCESS_ONCE(lock->tickets.head);
>>>>
>>>>  	for (;;) {
>>>> -		struct __raw_tickets tmp = ACCESS_ONCE(lock->tickets);
>>>> +		struct __raw_tickets tmp = READ_ONCE(lock->tickets);
>>>
>>> Agreed, but what about another ACCESS_ONCE() above?
>>>
>>> Oleg.
>>
>> tickets.head is a scalar type, so ACCESS_ONCE does work fine with gcc 4.6/4.7.
>> My goal was to convert all accesses on non-scalar types
> 
> I understand, but READ_ONCE(lock->tickets.head) looks better anyway and
> arch_spin_lock() already use READ_ONCE() for this.
> 
> So why we should keep the last ACCESS_ONCE() in spinlock.h ? Just to make
> another cosmetic cleanup which touches the same function later?

OK, I will change that one as well.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
