Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B3E9A6B01C3
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 14:03:42 -0400 (EDT)
Received: by fg-out-1718.google.com with SMTP id l26so1024823fgb.8
        for <linux-mm@kvack.org>; Tue, 23 Mar 2010 11:03:39 -0700 (PDT)
Subject: Re: [Bugme-new] [Bug 15618] New: 2.6.18->2.6.32->2.6.33 huge regression in performance
Mime-Version: 1.0 (Apple Message framework v1077)
Content-Type: text/plain; charset=us-ascii
From: Anton Starikov <ant.starikov@gmail.com>
In-Reply-To: <20100323180002.GA2965@elte.hu>
Date: Tue, 23 Mar 2010 19:03:36 +0100
Content-Transfer-Encoding: quoted-printable
Message-Id: <15090451-C292-44D6-B2BA-DCBCBEEF429D@gmail.com>
References: <bug-15618-10286@https.bugzilla.kernel.org/> <20100323102208.512c16cc.akpm@linux-foundation.org> <20100323173409.GA24845@elte.hu> <alpine.LFD.2.00.1003231037410.18017@i5.linux-foundation.org> <20100323180002.GA2965@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>


On Mar 23, 2010, at 7:00 PM, Ingo Molnar wrote:
>> NOTE! None of those are in 2.6.33 - they were merged afterwards. But =
they=20
>> are in 2.6.34-rc1 (and obviously current -git). So Anton would have =
to=20
>> compile his own kernel to test his load.
>=20
> another option is to run the rawhide kernel via something like:
>=20
> 	yum update --enablerepo=3Ddevelopment kernel
>=20
> this will give kernel-2.6.34-0.13.rc1.git1.fc14.x86_64, which has =
those=20
> changes included.

I will apply this commits to 2.6.32, I afraid current OFED (which I need =
also) will not work on 2.6.33+.

Anton.=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
