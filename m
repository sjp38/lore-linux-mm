Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 48EAF6B01B5
	for <linux-mm@kvack.org>; Sat, 27 Mar 2010 06:56:09 -0400 (EDT)
Received: by pwi2 with SMTP id 2so2106243pwi.14
        for <linux-mm@kvack.org>; Sat, 27 Mar 2010 03:56:08 -0700 (PDT)
MIME-Version: 1.0
Date: Sat, 27 Mar 2010 11:56:08 +0100
Message-ID: <17cb70ee1003270356g7fba07b0xf558583484748dc3@mail.gmail.com>
Subject: On using allocation in sysctl handler
From: Auguste Mome <augustmome@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,
I added an allocation GFP_KERNEL inside a sysctl handler and got the error
BUG: sleeping function called from invalid context
in_atomic(): 1, irqs_disabled(): 0, pid: 723, name: sysctl

Is it obvious error and I should use GFP_ATOMIC?
I guess yes, but it just happens since I switched to a 2.6.30 on ppc, and it did
not happen on 2.6.30 x86.
So I'm not sure if something is wrong on ppc, of if something changed
recently in sysctl,
or simply my code was wrong and the check has improved in memory system.

Thanks,
Auguste.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
