Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 742F38D0001
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 21:42:33 -0400 (EDT)
Subject: Re:[PATCH v2]oom-kill: CAP_SYS_RESOURCE should get bonus
From: "Figo.zhang" <zhangtianfei@leadcoretech.com>
In-Reply-To: <AANLkTimjfmLzr_9+Sf4gk0xGkFjffQ1VcCnwmCXA88R8@mail.gmail.com>
References: <1288662213.10103.2.camel@localhost.localdomain>
	 <1288827804.2725.0.camel@localhost.localdomain>
	 <alpine.DEB.2.00.1011031646110.7830@chino.kir.corp.google.com>
	 <AANLkTimjfmLzr_9+Sf4gk0xGkFjffQ1VcCnwmCXA88R8@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 04 Nov 2010 09:38:57 +0800
Message-ID: <1288834737.2124.11.camel@myhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: figo zhang <figo1802@gmail.com>, David Rientjes <rientjes@google.com>
Cc: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>


> 
> 
> 
> On Thu, 4 Nov 2010, Figo.zhang wrote:
> 
> > CAP_SYS_RESOURCE also had better get 3% bonus for protection.
> >
> 
> 
> Would you like to elaborate as to why?
> 
> 

process with CAP_SYS_RESOURCE capibility which have system resource
limits, like journaling resource on ext3/4 filesystem, RTC clock. so it
also the same treatment as process with CAP_SYS_ADMIN.

Best,

Figo.zhang



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
