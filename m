Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3UAxx5i011104
	for <linux-mm@kvack.org>; Wed, 30 Apr 2008 06:59:59 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3UB2eks121512
	for <linux-mm@kvack.org>; Wed, 30 Apr 2008 05:02:40 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3UB2eca002117
	for <linux-mm@kvack.org>; Wed, 30 Apr 2008 05:02:40 -0600
Subject: Re: [PATCH] procfs task exe symlink
From: Matt Helsley <matthltc@us.ibm.com>
In-Reply-To: <20080426162458.GJ5882@ZenIV.linux.org.uk>
References: <1202348669.9062.271.camel@localhost.localdomain>
	 <20080426091930.ffe4e6a8.akpm@linux-foundation.org>
	 <20080426162458.GJ5882@ZenIV.linux.org.uk>
Content-Type: text/plain
Date: Wed, 30 Apr 2008 04:02:38 -0700
Message-Id: <1209553358.29759.24.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@tv-sign.ru>, David Howells <dhowells@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Christoph Hellwig <chellwig@de.ibm.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Sat, 2008-04-26 at 17:24 +0100, Al Viro wrote:
> On Sat, Apr 26, 2008 at 09:19:30AM -0700, Andrew Morton wrote:
> 
> > +	set_mm_exe_file(bprm->mm, bprm->file);
> > +
> >  	/*
> >  	 * Release all of the old mmap stuff
> >  	 */
> > 
> > However I'd ask that you conform that this is OK.  If set_mm_exe_file() is
> > independent of unshare_files() then we're OK.  If however there is some
> > ordering dependency then we'll need to confirm that the present ordering of the
> > unshare_files() and set_mm_exe_file() is correct.
> 
> No, that's fine (unshare_files() had to go up for a lot of reasons, one
> of them being that it can fail and de_thread() called just above is
> very much irreversible).

They are independent. It just needs to be called before exec_mmap() --
so your fix looks good.

Cheers,
	-Matt Helsley

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
