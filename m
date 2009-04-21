Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C57036B0062
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 23:00:11 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH 0/4] ksm - dynamic page sharing driver for linux v3
Date: Tue, 21 Apr 2009 12:59:58 +1000
References: <1239249521-5013-1-git-send-email-ieidus@redhat.com> <200904170355.26294.nickpiggin@yahoo.com.au> <6934efce0904170008p45cba2c4l3e9ca9f8775c7bde@mail.gmail.com>
In-Reply-To: <6934efce0904170008p45cba2c4l3e9ca9f8775c7bde@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200904211259.59752.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Jared Hulbert <jaredeh@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, aarcange@redhat.com, chrisw@redhat.com, mtosatti@redhat.com, hugh@veritas.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Friday 17 April 2009 17:08:07 Jared Hulbert wrote:
> > As everyone knows, my favourite thing is to say nasty things about any
> > new feature that adds complexity to common code. I feel like crying to
> > hear about how many more instances of MS Office we can all run, if only
> > we apply this patch. And the poorly written HPC app just sounds like
> > scrapings from the bottom of justification barrel.
> >
> > I'm sorry, maybe I'm way off with my understanding of how important
> > this is. There isn't too much help in the changelog. A discussion of
> > where the memory savings comes from, and how far does things like
> > sharing of fs image, or ballooning goes and how much extra savings we
> > get from this... with people from other hypervisors involved as well.
> > Have I missed this kind of discussion?
> 
> Nick,
> 
> I don't know about other hypervisors, fs and balloonings, but I have
> tried this out.  It works.  It works on apps I don't consider, "poorly
> written".  I'm very excited about this.  I got >10% saving in a
> roughly off the shelf embedded system.  No user noticeable performance
> impact.

OK well that's what I want to hear. Thanks, that means a lot to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
