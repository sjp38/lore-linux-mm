Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id C44016B0032
	for <linux-mm@kvack.org>; Thu,  9 May 2013 10:13:34 -0400 (EDT)
Date: Thu, 9 May 2013 15:13:29 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH V1 0/6] mm: add a new option MREMAP_DUP to mmrep
 syscall
Message-ID: <20130509141329.GC11497@suse.de>
References: <1368093011-4867-1-git-send-email-wenchaolinux@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1368093011-4867-1-git-send-email-wenchaolinux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wenchaolinux@gmail.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, hughd@google.com, walken@google.com, viro@zeniv.linux.org.uk, kirill.shutemov@linux.intel.com, xiaoguangrong@linux.vnet.ibm.com, anthony@codemonkey.ws, stefanha@gmail.com

On Thu, May 09, 2013 at 05:50:05PM +0800, wenchaolinux@gmail.com wrote:
> From: Wenchao Xia <wenchaolinux@gmail.com>
> 
>   This serial try to enable mremap syscall to cow some private memory region,
> just like what fork() did. As a result, user space application would got a
> mirror of those region, and it can be used as a snapshot for further processing.
> 

What not just fork()? Even if the application was threaded it should be
managable to handle fork just for processing the private memory region
in question. I'm having trouble figuring out what sort of application
would require an interface like this.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
