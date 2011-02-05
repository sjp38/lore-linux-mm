Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E4FF58D0039
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 21:32:58 -0500 (EST)
Date: Fri, 4 Feb 2011 18:31:26 -0800
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: mmotm 2011-02-04-15-15 uploaded (printk
 DEFAULT_MESSAGE_LOGLEVEL)
Message-Id: <20110204183126.ac5c2d66.randy.dunlap@oracle.com>
In-Reply-To: <201102042349.p14NnQEm025834@imap1.linux-foundation.org>
References: <201102042349.p14NnQEm025834@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Mandeep Singh Baines <msb@chromium.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Fri, 04 Feb 2011 15:15:17 -0800 akpm@linux-foundation.org wrote:

> The mm-of-the-moment snapshot 2011-02-04-15-15 has been uploaded to
> 
>    http://userweb.kernel.org/~akpm/mmotm/
> 
> and will soon be available at
> 
>    git://zen-kernel.org/kernel/mmotm.git
> 
> It contains the following patches against 2.6.38-rc3:

When CONFIG_PRINTK is not enabled:

mmotm-2011-0204-1515/kernel/printk.c:66: error: 'CONFIG_DEFAULT_MESSAGE_LOGLEVEL' undeclared here (not in a function)

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
