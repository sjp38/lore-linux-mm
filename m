Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3BD055F0001
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 13:54:49 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH 0/4] ksm - dynamic page sharing driver for linux v3
Date: Fri, 17 Apr 2009 03:55:24 +1000
References: <1239249521-5013-1-git-send-email-ieidus@redhat.com> <20090414150903.b01fa3b9.akpm@linux-foundation.org>
In-Reply-To: <20090414150903.b01fa3b9.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Disposition: inline
Message-Id: <200904170355.26294.nickpiggin@yahoo.com.au>
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, aarcange@redhat.com, chrisw@redhat.com, mtosatti@redhat.com, hugh@veritas.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Wednesday 15 April 2009 08:09:03 Andrew Morton wrote:
> On Thu,  9 Apr 2009 06:58:37 +0300
> Izik Eidus <ieidus@redhat.com> wrote:
> 
> > KSM is a linux driver that allows dynamicly sharing identical memory
> > pages between one or more processes.
> 
> Generally looks OK to me.  But that doesn't mean much.  We should rub
> bottles with words like "hugh" and "nick" on them to be sure.

I haven't looked too closely at it yet sorry. Hugh has a great eye for
these details, though, hint hint :)

As everyone knows, my favourite thing is to say nasty things about any
new feature that adds complexity to common code. I feel like crying to
hear about how many more instances of MS Office we can all run, if only
we apply this patch. And the poorly written HPC app just sounds like
scrapings from the bottom of justification barrel.

I'm sorry, maybe I'm way off with my understanding of how important
this is. There isn't too much help in the changelog. A discussion of
where the memory savings comes from, and how far does things like
sharing of fs image, or ballooning goes and how much extra savings we
get from this... with people from other hypervisors involved as well.
Have I missed this kind of discussion?

Careful what you wish for, ay? :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
