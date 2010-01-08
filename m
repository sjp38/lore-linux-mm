Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 839366B0044
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 14:31:17 -0500 (EST)
Received: by ewy24 with SMTP id 24so26200593ewy.6
        for <linux-mm@kvack.org>; Fri, 08 Jan 2010 11:31:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4B478689.5020907@redhat.com>
References: <1262700774-1808-1-git-send-email-gleb@redhat.com>
	<20100108161828.GA30404@amt.cnet> <4B478689.5020907@redhat.com>
From: Bryan Donlan <bdonlan@gmail.com>
Date: Fri, 8 Jan 2010 14:30:55 -0500
Message-ID: <3e8340491001081130v2adb8e07k3b32f7f860daf603@mail.gmail.com>
Subject: Re: [PATCH v3 00/12] KVM: Add host swap event notifications for PV
	guest
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Gleb Natapov <gleb@redhat.com>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, Jan 8, 2010 at 2:24 PM, Rik van Riel <riel@redhat.com> wrote:
> On 01/08/2010 11:18 AM, Marcelo Tosatti wrote:
>
>> - Limit the number of queued async pf's per guest ?
>
> This is automatically limited to the number of processes
> running in a guest :)

Only if the guest is nice and plays by the rules. What is to stop a
malicious guest from just immediately switching back to userspace and
kicking off another page-in every time it gets an async PF?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
