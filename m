Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6B4F56B004F
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 17:49:43 -0400 (EDT)
Received: from spaceape9.eur.corp.google.com (spaceape9.eur.corp.google.com [172.28.16.143])
	by smtp-out.google.com with ESMTP id n6SLngR2027739
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 22:49:43 +0100
Received: from wf-out-1314.google.com (wff28.prod.google.com [10.142.6.28])
	by spaceape9.eur.corp.google.com with ESMTP id n6SLnd0D011570
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 14:49:40 -0700
Received: by wf-out-1314.google.com with SMTP id 28so88192wff.12
        for <linux-mm@kvack.org>; Tue, 28 Jul 2009 14:49:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1786ab030907281211x6e432ba6ha6afe9de73f24e0c@mail.gmail.com>
References: <1786ab030907281211x6e432ba6ha6afe9de73f24e0c@mail.gmail.com>
Date: Tue, 28 Jul 2009 14:49:38 -0700
Message-ID: <33307c790907281449k5e8d4f6cib2c93848f5ec2661@mail.gmail.com>
Subject: Re: Bug in kernel 2.6.31, Slow wb_kupdate writeout
From: Martin Bligh <mbligh@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Chad Talbott <ctalbott@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, wfg@mail.ustc.edu.cn, Michael Rubin <mrubin@google.com>, Andrew Morton <akpm@google.com>, sandeen@redhat.com
List-ID: <linux-mm.kvack.org>

> An interesting recent-ish change is "writeback: speed up writeback of
> big dirty files." =A0When I revert the change to __sync_single_inode the
> problem appears to go away and background writeout proceeds at disk
> speed. =A0Interestingly, that code is in the git commit [2], but not in
> the post to LKML. [3] =A0This is may not be the fix, but it makes this
> test behave better.

I'm fairly sure this is not fixing the root cause - but putting it at the h=
ead
rather than the tail of the queue causes the error not to starve wb_kupdate
for nearly so long - as long as we keep the queue full, the bug is hidden.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
