Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id DBDF56B0044
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 14:56:03 -0500 (EST)
Message-ID: <4B478DBC.6010502@redhat.com>
Date: Fri, 08 Jan 2010 14:55:40 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 00/12] KVM: Add host swap event notifications for PV
 	guest
References: <1262700774-1808-1-git-send-email-gleb@redhat.com> 	<20100108161828.GA30404@amt.cnet> <4B478689.5020907@redhat.com> <3e8340491001081130v2adb8e07k3b32f7f860daf603@mail.gmail.com>
In-Reply-To: <3e8340491001081130v2adb8e07k3b32f7f860daf603@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Bryan Donlan <bdonlan@gmail.com>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Gleb Natapov <gleb@redhat.com>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On 01/08/2010 02:30 PM, Bryan Donlan wrote:
> On Fri, Jan 8, 2010 at 2:24 PM, Rik van Riel<riel@redhat.com>  wrote:
>> On 01/08/2010 11:18 AM, Marcelo Tosatti wrote:
>>
>>> - Limit the number of queued async pf's per guest ?
>>
>> This is automatically limited to the number of processes
>> running in a guest :)
>
> Only if the guest is nice and plays by the rules. What is to stop a
> malicious guest from just immediately switching back to userspace and
> kicking off another page-in every time it gets an async PF?

Good point, a malicious guest could do that and ruin
things for everyone.  I guess we do need a limit :)

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
