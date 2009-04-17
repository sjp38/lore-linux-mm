Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 011265F0001
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 03:08:00 -0400 (EDT)
Received: by yw-out-1718.google.com with SMTP id 4so506634ywq.26
        for <linux-mm@kvack.org>; Fri, 17 Apr 2009 00:08:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <200904170355.26294.nickpiggin@yahoo.com.au>
References: <1239249521-5013-1-git-send-email-ieidus@redhat.com>
	 <20090414150903.b01fa3b9.akpm@linux-foundation.org>
	 <200904170355.26294.nickpiggin@yahoo.com.au>
Date: Fri, 17 Apr 2009 00:08:07 -0700
Message-ID: <6934efce0904170008p45cba2c4l3e9ca9f8775c7bde@mail.gmail.com>
Subject: Re: [PATCH 0/4] ksm - dynamic page sharing driver for linux v3
From: Jared Hulbert <jaredeh@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, aarcange@redhat.com, chrisw@redhat.com, mtosatti@redhat.com, hugh@veritas.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

> As everyone knows, my favourite thing is to say nasty things about any
> new feature that adds complexity to common code. I feel like crying to
> hear about how many more instances of MS Office we can all run, if only
> we apply this patch. And the poorly written HPC app just sounds like
> scrapings from the bottom of justification barrel.
>
> I'm sorry, maybe I'm way off with my understanding of how important
> this is. There isn't too much help in the changelog. A discussion of
> where the memory savings comes from, and how far does things like
> sharing of fs image, or ballooning goes and how much extra savings we
> get from this... with people from other hypervisors involved as well.
> Have I missed this kind of discussion?

Nick,

I don't know about other hypervisors, fs and balloonings, but I have
tried this out.  It works.  It works on apps I don't consider, "poorly
written".  I'm very excited about this.  I got >10% saving in a
roughly off the shelf embedded system.  No user noticeable performance
impact.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
