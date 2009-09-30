Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5C3976B0082
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 12:14:55 -0400 (EDT)
Subject: Re: [PATCH 00/80] Kernel based checkpoint/restart [v18]
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
	<20090924154139.2a7dd5ec.akpm@linux-foundation.org>
	<20090928163704.GA3327@us.ibm.com> <4AC20BB8.4070509@free.fr>
	<87iqf0o5sf.fsf@caffeine.danplanet.com> <4AC38477.4070007@free.fr>
From: Dan Smith <danms@us.ibm.com>
Date: Wed, 30 Sep 2009 09:29:23 -0700
In-Reply-To: <4AC38477.4070007@free.fr> (Daniel Lezcano's message of "Wed\, 30 Sep 2009 18\:16\:55 +0200")
Message-ID: <87eipoo0po.fsf@caffeine.danplanet.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Daniel Lezcano <daniel.lezcano@free.fr>
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, mingo@elte.hu, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

DL> If the checkpoint is done from the kernel, why the restart
DL> wouldn't be in the kernel too ?

I think thus far we have taken the approach of "if it can be done
reasonably in userspace, then do it there" right?  Setup of the
network devices is easy to do in userspace, allows more flexibility
from a policy standpoint, and ensures that all existing security
checks are performed.  Also, migration may be easier if the userspace
bits can call custom hooks allowing for routing changes and other
infrastructure-specific operations.

DL> Is there any documentation about the statefile format I can use if
DL> I want to implement myself an userspace CR solution based on this
DL> kernel patchset ?

See linux-cr/include/linux/checkpoint_hdr.h and user-cr/restart.c.

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
