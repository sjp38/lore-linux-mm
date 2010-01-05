Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 0A3F26007E1
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 11:05:08 -0500 (EST)
Message-ID: <4B43631A.2030101@redhat.com>
Date: Tue, 05 Jan 2010 18:04:42 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 00/12] KVM: Add host swap event notifications for PV
 	guest
References: <1262700774-1808-1-git-send-email-gleb@redhat.com> <fdaac4d51001050705s3f46dd0fi948a3b3ea803fa51@mail.gmail.com>
In-Reply-To: <fdaac4d51001050705s3f46dd0fi948a3b3ea803fa51@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jun Koi <junkoi2004@gmail.com>
Cc: Gleb Natapov <gleb@redhat.com>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On 01/05/2010 05:05 PM, Jun Koi wrote:
> Is it true that to make this work, we will need a (PV) kernel driver
> for each guest OS (Windows, Linux, ...)?
>
>    

It's partially usable even without guest modifications; while servicing 
a host page fault we can still deliver interrupts to the guest (which 
might cause a context switch and thus further progress to be made).

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
