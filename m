Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 272F96B0011
	for <linux-mm@kvack.org>; Wed, 18 May 2011 15:33:57 -0400 (EDT)
Date: Wed, 18 May 2011 12:33:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/4] v6 Improve task->comm locking situation
Message-Id: <20110518123335.62785884.akpm@linux-foundation.org>
In-Reply-To: <1305745409.2915.178.camel@work-vm>
References: <1305682865-27111-1-git-send-email-john.stultz@linaro.org>
	<20110518062554.GB2945@elte.hu>
	<1305745409.2915.178.camel@work-vm>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: Ingo Molnar <mingo@elte.hu>, LKML <linux-kernel@vger.kernel.org>, Joe Perches <joe@perches.com>, Michal Nazarewicz <mina86@mina86.com>, Andy Whitcroft <apw@canonical.com>, Jiri Slaby <jirislaby@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>

On Wed, 18 May 2011 12:03:29 -0700
John Stultz <john.stultz@linaro.org> wrote:

> But, the net of this is that it seems everyone else is way more
> passionate about this issue then I am, so I'm starting to wonder if it
> would be better for someone who has more of a dog in the fight to be
> pushing these?

I like the %p thingy - it's neat and is an overall improvement.  If it
dies I shall stick another pin in my Ingo doll.

Providing an unlocked accessor for super-special applications which
know what they're doing seems an adequate compromise.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
