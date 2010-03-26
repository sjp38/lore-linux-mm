Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 2CC9A6B01B3
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 23:25:01 -0400 (EDT)
Received: by bwz19 with SMTP id 19so343194bwz.6
        for <linux-mm@kvack.org>; Thu, 25 Mar 2010 20:24:59 -0700 (PDT)
Subject: Re: [Bugme-new] [Bug 15618] New: 2.6.18->2.6.32->2.6.33 huge regression in performance
Mime-Version: 1.0 (Apple Message framework v1077)
Content-Type: text/plain; charset=us-ascii
From: Anton Starikov <ant.starikov@gmail.com>
In-Reply-To: <adapr2t1xm8.fsf@roland-alpha.cisco.com>
Date: Fri, 26 Mar 2010 04:24:56 +0100
Content-Transfer-Encoding: quoted-printable
Message-Id: <7AA94EEA-D9D7-4979-B9B2-890EF651D7C6@gmail.com>
References: <bug-15618-10286@https.bugzilla.kernel.org/> <20100323102208.512c16cc.akpm@linux-foundation.org> <20100323173409.GA24845@elte.hu> <alpine.LFD.2.00.1003231037410.18017@i5.linux-foundation.org> <20100323180002.GA2965@elte.hu> <15090451-C292-44D6-B2BA-DCBCBEEF429D@gmail.com> <adapr2t1xm8.fsf@roland-alpha.cisco.com>
Sender: owner-linux-mm@kvack.org
To: Roland Dreier <rdreier@cisco.com>
Cc: Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Mar 24, 2010, at 5:40 PM, Roland Dreier wrote:

>> I will apply this commits to 2.6.32, I afraid current OFED (which I
>> need also) will not work on 2.6.33+.
>=20
> What do you need from OFED that is not in 2.6.34-rc1?

I didn't go too 2.6.34-rc1.
I tried 2.6.33, mlx4 driver which comes with kernel produces panic on my =
hardwire. And OFED-1.5 doesn't support this kernel (probably it still =
can be compiled, didn't check).

Anton.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
