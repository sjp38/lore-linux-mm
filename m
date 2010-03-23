Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 5F4156B01B9
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 16:44:00 -0400 (EDT)
Received: by bwz19 with SMTP id 19so5584807bwz.6
        for <linux-mm@kvack.org>; Tue, 23 Mar 2010 13:43:58 -0700 (PDT)
Subject: Re: [Bugme-new] [Bug 15618] New: 2.6.18->2.6.32->2.6.33 huge regression in performance
Mime-Version: 1.0 (Apple Message framework v1077)
Content-Type: text/plain; charset=us-ascii
From: Anton Starikov <ant.starikov@gmail.com>
In-Reply-To: <alpine.LFD.2.00.1003231253570.18017@i5.linux-foundation.org>
Date: Tue, 23 Mar 2010 21:43:54 +0100
Content-Transfer-Encoding: quoted-printable
Message-Id: <9FC34DA1-D6DD-41E5-8B76-0712A813C549@gmail.com>
References: <bug-15618-10286@https.bugzilla.kernel.org/> <20100323102208.512c16cc.akpm@linux-foundation.org> <20100323173409.GA24845@elte.hu> <alpine.LFD.2.00.1003231037410.18017@i5.linux-foundation.org> <9D040E9A-80F2-468F-A6CD-A4912615CD3F@gmail.com> <alpine.LFD.2.00.1003231253570.18017@i5.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

I think we got a winner!

Problem seems to be fixed.

Just for record, I used next patches:

59c33fa7791e9948ba467c2b83e307a0d087ab49
5d0b7235d83eefdafda300656e97d368afcafc9a
1838ef1d782f7527e6defe87e180598622d2d071
4126faf0ab7417fbc6eb99fb0fd407e01e9e9dfe
bafaecd11df15ad5b1e598adc7736afcd38ee13d
0d1622d7f526311d87d7da2ee7dd14b73e45d3fc


Thanks,
Anton.

On Mar 23, 2010, at 8:54 PM, Linus Torvalds wrote:

>=20
>=20
> On Tue, 23 Mar 2010, Anton Starikov wrote:
>=20
>>=20
>> On Mar 23, 2010, at 6:45 PM, Linus Torvalds wrote:
>>=20
>>>=20
>>>=20
>>> On Tue, 23 Mar 2010, Ingo Molnar wrote:
>>>>=20
>>>> It shows a very brutal amount of page fault invoked mmap_sem =
spinning=20
>>>> overhead.
>>>=20
>>> Isn't this already fixed? It's the same old "x86-64 rwsemaphores are =
using=20
>>> the shit-for-brains generic version" thing, and it's fixed by
>>>=20
>>> 	1838ef1 x86-64, rwsem: 64-bit xadd rwsem implementation
>>> 	5d0b723 x86: clean up rwsem type system
>>> 	59c33fa x86-32: clean up rwsem inline asm statements
>>>=20
>>> NOTE! None of those are in 2.6.33 - they were merged afterwards. But =
they=20
>>> are in 2.6.34-rc1 (and obviously current -git). So Anton would have =
to=20
>>> compile his own kernel to test his load.
>>=20
>>=20
>> Applied mentioned patches. Things didn't improve too much.
>=20
> Yeah, I missed at least one commit, namely
>=20
> 	bafaecd x86-64: support native xadd rwsem implementation
>=20
> which is the one that actually makes x86-64 able to use the xadd =
version.
>=20
> 		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
