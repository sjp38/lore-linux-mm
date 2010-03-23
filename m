Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D78636B01D0
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 15:50:24 -0400 (EDT)
Received: by fxm10 with SMTP id 10so1142022fxm.30
        for <linux-mm@kvack.org>; Tue, 23 Mar 2010 12:50:21 -0700 (PDT)
Subject: Re: [Bugme-new] [Bug 15618] New: 2.6.18->2.6.32->2.6.33 huge regression in performance
Mime-Version: 1.0 (Apple Message framework v1077)
Content-Type: text/plain; charset=us-ascii
From: Anton Starikov <ant.starikov@gmail.com>
In-Reply-To: <20100323192213.GA6169@sgi.com>
Date: Tue, 23 Mar 2010 20:50:18 +0100
Content-Transfer-Encoding: quoted-printable
Message-Id: <2311E292-F8FE-4C80-A0DA-738CFAE71C50@gmail.com>
References: <bug-15618-10286@https.bugzilla.kernel.org/> <20100323102208.512c16cc.akpm@linux-foundation.org> <20100323173409.GA24845@elte.hu> <alpine.LFD.2.00.1003231037410.18017@i5.linux-foundation.org> <20100323180002.GA2965@elte.hu> <15090451-C292-44D6-B2BA-DCBCBEEF429D@gmail.com> <20100323112141.7f248f2b.akpm@linux-foundation.org> <41DAB29F-59B7-4D38-A389-75FAC47225BF@gmail.com> <20100323192213.GA6169@sgi.com>
Sender: owner-linux-mm@kvack.org
To: Robin Holt <holt@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>


On Mar 23, 2010, at 8:22 PM, Robin Holt wrote:

> On Tue, Mar 23, 2010 at 07:25:43PM +0100, Anton Starikov wrote:
>> On Mar 23, 2010, at 7:21 PM, Andrew Morton wrote:
>>>> I will apply this commits to 2.6.32, I afraid current OFED (which I =
need also) will not work on 2.6.33+.
>>>>=20
>>>=20
>>> You should be able to simply set CONFIG_RWSEM_GENERIC_SPINLOCK=3Dn,
>>> CONFIG_RWSEM_XCHGADD_ALGORITHM=3Dy by hand, as I mentioned earlier?
>>=20
>> Hm. I tried, but when I do "make oldconfig", then it gets rewritten, =
so I assume that it conflicts with some other setting from default =
fedora kernel config. trying to figure out which one exactly.
>=20
> Have you tracked this down yet?  I just got the patches applied =
against
> an older kernel and am running into the same issue.


I think you can prevent overwriting this options if you set them in =
arch/x86/configs/x86_64_defconfig

Anton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
