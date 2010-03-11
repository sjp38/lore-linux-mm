Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D43DD6B00EC
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 13:43:31 -0500 (EST)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id o2BIhQbj029308
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 18:43:27 GMT
Received: from fxm21 (fxm21.prod.google.com [10.184.13.21])
	by wpaz33.hot.corp.google.com with ESMTP id o2BIganC012516
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 10:43:25 -0800
Received: by fxm21 with SMTP id 21so383685fxm.11
        for <linux-mm@kvack.org>; Thu, 11 Mar 2010 10:43:24 -0800 (PST)
Date: Thu, 11 Mar 2010 18:43:12 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] kvm : remove redundant initialization of page->private
In-Reply-To: <4B98B018.4020103@redhat.com>
Message-ID: <alpine.LSU.2.00.1003111835330.5991@sister.anvils>
References: <1268040782-28561-1-git-send-email-shijie8@gmail.com>  <1268065219.1254.12.camel@barrios-desktop>  <4B977244.4010603@redhat.com> <1268231482.1254.28.camel@barrios-desktop> <4B989EE2.30803@redhat.com> <4B98AF1B.80701@siemens.com>
 <4B98B018.4020103@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Jan Kiszka <jan.kiszka@siemens.com>, Minchan Kim <minchan.kim@gmail.com>, Huang Shijie <shijie8@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 11 Mar 2010, Avi Kivity wrote:
> On 03/11/2010 10:51 AM, Jan Kiszka wrote:
> > >      
> > Thanks for pointing out! Since which kernel can we rely on the implicit
> > set_page_private?
> 
> Um, git blame shows it goes all the way back to 2.6.12.  So it was redundant
> all along.

Not that it matters at all, but no, that was just the dawning of the git age.
prep_new_page() started initializing page->private in 2.6.0-test3:

<akpm@osdl.org>
	[PATCH] initialise page->private
	
	From: Nathan Scott <nathans@sgi.com>
	
	XFS wants to use page->private as a bitmap of uptodate indicators for
	sub-page-sized blocks (which is one of the things ->provate was intended
	for).
	
	But someone needs to initialise ->private somewhere.  best to do it in the
	page allocator, so the zeroness of a new page's ->private becomes a
	system-wide thing.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
