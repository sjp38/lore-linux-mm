Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C456A6B01C7
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 14:19:29 -0400 (EDT)
Received: by pwj1 with SMTP id 1so4495830pwj.9
        for <linux-mm@kvack.org>; Tue, 23 Mar 2010 11:19:27 -0700 (PDT)
Subject: Re: [Bugme-new] [Bug 15618] New: 2.6.18->2.6.32->2.6.33 huge regression in performance
Mime-Version: 1.0 (Apple Message framework v1077)
Content-Type: text/plain; charset=us-ascii
From: Anton Starikov <ant.starikov@gmail.com>
In-Reply-To: <20100323111351.756c8752.akpm@linux-foundation.org>
Date: Tue, 23 Mar 2010 19:19:22 +0100
Content-Transfer-Encoding: quoted-printable
Message-Id: <1BAC48C3-2AF2-4FA2-9762-85727068BF64@gmail.com>
References: <bug-15618-10286@https.bugzilla.kernel.org/> <20100323102208.512c16cc.akpm@linux-foundation.org> <20100323173409.GA24845@elte.hu> <20100323111351.756c8752.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Mar 23, 2010, at 7:13 PM, Andrew Morton wrote:
> Anton, we have an executable binary in the bugzilla report but it =
would
> be nice to also have at least a description of what that code is
> actually doing.  A quick strace shows quite a lot of mprotect =
activity.
> A pseudo-code walkthrough, perhaps?


Right now can't say too much about the code (we just gave a chance to =
neighbor group to run their code on our cluster, so I'm totally =
unfriendly with this code). I will forward your question to them.

But probably right now you can get more information (including sources) =
here http://fmt.cs.utwente.nl/tools/ltsmin/

Anton=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
