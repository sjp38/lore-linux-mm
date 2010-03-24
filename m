Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B50A96B01EC
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 12:40:53 -0400 (EDT)
From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [Bugme-new] [Bug 15618] New: 2.6.18->2.6.32->2.6.33 huge regression in performance
References: <bug-15618-10286@https.bugzilla.kernel.org/>
	<20100323102208.512c16cc.akpm@linux-foundation.org>
	<20100323173409.GA24845@elte.hu>
	<alpine.LFD.2.00.1003231037410.18017@i5.linux-foundation.org>
	<20100323180002.GA2965@elte.hu>
	<15090451-C292-44D6-B2BA-DCBCBEEF429D@gmail.com>
Date: Wed, 24 Mar 2010 09:40:47 -0700
In-Reply-To: <15090451-C292-44D6-B2BA-DCBCBEEF429D@gmail.com> (Anton
	Starikov's message of "Tue, 23 Mar 2010 19:03:36 +0100")
Message-ID: <adapr2t1xm8.fsf@roland-alpha.cisco.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Anton Starikov <ant.starikov@gmail.com>
Cc: Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

 > I will apply this commits to 2.6.32, I afraid current OFED (which I
 > need also) will not work on 2.6.33+.

What do you need from OFED that is not in 2.6.34-rc1?
-- 
Roland Dreier  <rolandd@cisco.com>
For corporate legal information go to:
http://www.cisco.com/web/about/doing_business/legal/cri/index.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
