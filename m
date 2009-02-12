Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id F327D6B0088
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 18:06:04 -0500 (EST)
Subject: Re: [RFC v13][PATCH 00/14] Kernel based checkpoint/restart
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <1234479457.30155.214.camel@nimitz>
References: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu>
	 <1234285547.30155.6.camel@nimitz>
	 <20090211141434.dfa1d079.akpm@linux-foundation.org>
	 <1234462282.30155.171.camel@nimitz>  <1234467035.3243.538.camel@calx>
	 <1234479457.30155.214.camel@nimitz>
Content-Type: text/plain
Date: Thu, 12 Feb 2009 17:05:24 -0600
Message-Id: <1234479924.3152.13.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, orenl@cs.columbia.edu, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, viro@zeniv.linux.org.uk, hpa@zytor.com, Thomas Gleixner <tglx@linutronix.de>, Cedric Le Goater <clg@fr.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2009-02-12 at 14:57 -0800, Dave Hansen wrote:
> > Also, what happens if I checkpoint a process in 2.6.30 and restore it in
> > 2.6.31 which has an expanded idea of what should be restored? Do your
> > file formats handle this sort of forward compatibility or am I
> > restricted to one kernel?
> 
> In general, you're restricted to one kernel.  But, people have mentioned
> that, if the formats change, we should be able to write in-userspace
> converters for the checkpoint files.  

I mentioned this because it seems like a key use case is upgrading
kernels out from under long-lived applications.

-- 
http://selenic.com : development and support for Mercurial and Linux


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
