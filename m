Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 1BD1B6B0071
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 03:17:31 -0400 (EDT)
Received: by iwn5 with SMTP id 5so650094iwn.14
        for <linux-mm@kvack.org>; Thu, 10 Jun 2010 00:17:29 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 10 Jun 2010 15:17:29 +0800
Message-ID: <AANLkTik6xP9vVEyW4QG-4RfZu-iEuHcl2pBV_-mfHP4y@mail.gmail.com>
Subject: oom killer and long-waiting processes
From: Ryan Wang <openspace.wang@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernelnewbies@nl.linux.org
List-ID: <linux-mm.kvack.org>

Hi all,

        I have one question about oom killer:
If many processes dealing with network communications,
but due to bad network traffic, the processes have to wait
for a very long time. And meanwhile they may consume
some memeory separately for computation. The number
of such processes may be large.

        I wonder whether oom killer will kill these processes
when the system is under high pressure?

thanks,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
