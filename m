Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id E85616B027C
	for <linux-mm@kvack.org>; Sat,  4 May 2013 18:29:48 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id w11so1459080pde.37
        for <linux-mm@kvack.org>; Sat, 04 May 2013 15:29:48 -0700 (PDT)
Date: Sat, 4 May 2013 15:29:45 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: The scan_unevictable_pages sysctl/node-interface has been disabled
 for lack of a legitimate use case. If you have one, please send an email to
 linux-mm@kvack.o
In-Reply-To: <e7a8f6493785bcd7662abb866227b94e@serbestinternet.com>
Message-ID: <alpine.DEB.2.02.1305041526510.799@chino.kir.corp.google.com>
References: <e7a8f6493785bcd7662abb866227b94e@serbestinternet.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: remzi@serbestinternet.com
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Sat, 4 May 2013, remzi@serbestinternet.com wrote:

> [20800.746321] The scan_unevictable_pages
> sysctl/node-interface has been disabled for lack of a legitimate use
> case. If you have one, please send an email to linux-mm@kvack.org." 
> 
> I
> could not understand this messages mean? 
>  

You must be using v3.2 before this warning message displayed the name of 
the process witing to the sysctl, so we unfortunately don't know what is 
writing to it in your userspace.  Could you upgrade to v3.3 or a later 
kernel and look for it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
