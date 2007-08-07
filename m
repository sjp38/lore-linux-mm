Received: from cragnux.laika.com ([209.162.219.253]:64654 helo=dogma.ljc.laika.com)
	by serv01.siteground137.com with esmtpsa (TLSv1:RC4-MD5:128)
	(Exim 4.63)
	(envelope-from <linux@j-davis.com>)
	id 1IICgG-0005RB-9N
	for linux-mm@kvack.org; Mon, 06 Aug 2007 19:12:12 -0500
Subject: OOM killer overcounts memory usage
From: Jeff Davis <linux@j-davis.com>
Content-Type: text/plain
Date: Mon, 06 Aug 2007 17:12:12 -0700
Message-Id: <1186445532.27681.28.camel@dogma.ljc.laika.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The OOM killer badness() function (mm/oom_kill.c) overcounts shared
memory many times over when the memory is shared between a parent
process and its children.

Each byte of shared memory is counted 1+N/2 times for the parent, where
N is the number of children of the process with which the parent shares
memory.

We may not even want to count the parent's shared memory at all, because
there's already limit with kernel.shmmax.

Regards,
        Jeff Davis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
