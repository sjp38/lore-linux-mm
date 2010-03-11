Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 497DB6B00EB
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 13:29:45 -0500 (EST)
Received: by iwn1 with SMTP id 1so343803iwn.22
        for <linux-mm@kvack.org>; Thu, 11 Mar 2010 10:29:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4B8FC6AC.4060801@teksavvy.com>
References: <f875e2fe1003032052p944f32ayfe9fe8cfbed056d4@mail.gmail.com>
	 <20100303224245.ae8d1f7a.akpm@linux-foundation.org>
	 <87f94c371003040617t4a4fcd0dt1c9fc0f50e6002c4@mail.gmail.com>
	 <4B8FC6AC.4060801@teksavvy.com>
Date: Thu, 11 Mar 2010 13:29:43 -0500
Message-ID: <87f94c371003111029s7c7daebgf691ab11e6bdda25@mail.gmail.com>
Subject: Re: Linux kernel - Libata bad block error handling to user mode
	program
From: Greg Freemyer <greg.freemyer@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Mark Lord <kernel@teksavvy.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, foo saa <foosaa@gmail.com>, linux-kernel@vger.kernel.org, linux-ide@vger.kernel.org, Jens Axboe <jens.axboe@oracle.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>
> But really.. isn't "hdparm --security-erase NULL /dev/sdX" good enough ???
>

This thread seems to have died off.  If there is a real problem, I
hope it picks back up.

Mark, as to your question the few times I've tried that the bios on
the test machine blocked the command.  So it may have some specific
utility, but it's a not a generic solution in my mind.

Greg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
