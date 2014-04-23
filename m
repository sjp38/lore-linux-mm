Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id 339766B0035
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 13:42:02 -0400 (EDT)
Received: by mail-ee0-f50.google.com with SMTP id c13so1034569eek.23
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 10:42:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id l41si4176074eef.218.2014.04.23.10.41.57
        for <linux-mm@kvack.org>;
        Wed, 23 Apr 2014 10:41:58 -0700 (PDT)
Date: Wed, 23 Apr 2014 13:41:31 -0400
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: mmotm 2014-04-22-15-20 uploaded (uml 32- and 64-bit defconfigs)
Message-ID: <20140423134131.778f0d0a@redhat.com>
In-Reply-To: <5357F405.20205@infradead.org>
References: <20140422222121.2FAB45A431E@corp2gmr1-2.hot.corp.google.com>
	<5357F405.20205@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-next@vger.kernel.org, nacc@linux.vnet.ibm.com

On Wed, 23 Apr 2014 10:10:29 -0700
Randy Dunlap <rdunlap@infradead.org> wrote:

> On 04/22/14 15:21, akpm@linux-foundation.org wrote:
> > The mm-of-the-moment snapshot 2014-04-22-15-20 has been uploaded to
> > 
> >    http://www.ozlabs.org/~akpm/mmotm/
> > 
> > mmotm-readme.txt says
> > 
> > README for mm-of-the-moment:
> > 
> > http://www.ozlabs.org/~akpm/mmotm/
> > 
> > This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> > more than once a week.
> > 
> > You will need quilt to apply these patches to the latest Linus release (3.x
> > or 3.x-rcY).  The series file is in broken-out.tar.gz and is duplicated in
> > http://ozlabs.org/~akpm/mmotm/series
> > 
> 
> include/linux/hugetlb.h:468:9: error: 'HPAGE_SHIFT' undeclared (first use in this function)

The patch adding HPAGE_SHIFT usage to hugetlb.h in current mmotm is this:

http://www.ozlabs.org/~akpm/mmotm/broken-out/hugetlb-ensure-hugepage-access-is-denied-if-hugepages-are-not-supported.patch

But I can't reproduce the issue to be sure what the problem is. Are you
building the kernel on 32bits? Can you provide the output of
"grep -i huge .config" or send your .config in private?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
