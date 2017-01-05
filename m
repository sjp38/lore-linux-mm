Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 371146B0069
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 07:56:22 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id c47so224149646qtc.4
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 04:56:22 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h125si18730536qkd.40.2017.01.05.04.56.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jan 2017 04:56:21 -0800 (PST)
Date: Thu, 5 Jan 2017 13:56:17 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 07/42] userfaultfd: non-cooperative: report all available
 features to userland
Message-ID: <20170105125617.GI6984@redhat.com>
References: <20161216144821.5183-1-aarcange@redhat.com>
 <20161216144821.5183-8-aarcange@redhat.com>
 <20170104150146.4c26286146460eafbdc77cb3@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170104150146.4c26286146460eafbdc77cb3@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

Hello Andrew,

On Wed, Jan 04, 2017 at 03:01:46PM -0800, Andrew Morton wrote:
> On Fri, 16 Dec 2016 15:47:46 +0100 Andrea Arcangeli <aarcange@redhat.com> wrote:
> 
> > This will allow userland to probe all features available in the
> > kernel. It will however only enable the requested features in the
> > open userfaultfd context.
> 
> Is the user-facing documentation updated somewhere?  I guess that's

The above is fully backwards compatible, in the current upstream the
feature flags are empty.

#define UFFD_API_FEATURES (0)

So it behaves the same.

> Documentation/vm/userfaultfd.txt.  Does a manpage exist yet?

The manpage is merged and in sync with the above comment, but it
wasn't updated for hugetlbfs shmem and non cooperative features
yet. It just documents the UFFD_API_FEATURES (0) behavior according to
the above git commit message.

Like Mike wrote below the manpage will be updated when the new
features go upstream.

https://marc.info/?l=linux-man&m=148299572702201&w=2
https://marc.info/?l=linux-man&m=148304176911503&w=2

Here the text in the current manpage relevant to the above commit, so
again in full sync with upstream and in sync with the new patch too
because upstream behaves the same with UFFD_API_FEATURES (0):

       The API ioctls are used to configure userfaultfd behavior.
       They allow to choose what features will be enabled and what
       kinds of events will be delivered to the application.

              The api field denotes the API version requested by the
              application.  The kernel verifies that it can support
              the required API, and sets the features and ioctls
              fields to bit masks representing all the available
              features and the generic ioctls available.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
