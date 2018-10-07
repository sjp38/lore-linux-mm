Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4D2876B000A
	for <linux-mm@kvack.org>; Sun,  7 Oct 2018 12:32:54 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id l204-v6so764597oia.17
        for <linux-mm@kvack.org>; Sun, 07 Oct 2018 09:32:54 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id a7-v6si6888499oii.107.2018.10.07.09.32.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Oct 2018 09:32:53 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w97GV2Jj115693
	for <linux-mm@kvack.org>; Sun, 7 Oct 2018 12:32:52 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2mynqtr1pp-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 07 Oct 2018 12:32:52 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Sun, 7 Oct 2018 17:32:50 +0100
Date: Sun, 7 Oct 2018 19:32:44 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] docs/vm: split memory hotplug notifier description
 to Documentation/core-api
References: <1538691061-31289-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1538691061-31289-3-git-send-email-rppt@linux.vnet.ibm.com>
 <20181007084640.76cd08c8@lwn.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181007084640.76cd08c8@lwn.net>
Message-Id: <20181007163243.GA1128@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: linux-doc@vger.kernel.org, linux-mm@kvack.org

On Sun, Oct 07, 2018 at 08:46:40AM -0600, Jonathan Corbet wrote:
> On Fri,  5 Oct 2018 01:11:01 +0300
> Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
> 
> > The memory hotplug notifier description is about kernel internals rather
> > than admin/user visible API. Place it appropriately.
> > 
> > Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> 
> One little nit...
> 
> >  Documentation/admin-guide/mm/memory-hotplug.rst    | 83 ---------------------
> >  Documentation/core-api/index.rst                   |  2 +
> >  Documentation/core-api/memory-hotplug-notifier.rst | 84 ++++++++++++++++++++++
> >  3 files changed, 86 insertions(+), 83 deletions(-)
> >  create mode 100644 Documentation/core-api/memory-hotplug-notifier.rst
> > 
> > diff --git a/Documentation/admin-guide/mm/memory-hotplug.rst b/Documentation/admin-guide/mm/memory-hotplug.rst
> > index a33090c..0b9c83e 100644
> > --- a/Documentation/admin-guide/mm/memory-hotplug.rst
> > +++ b/Documentation/admin-guide/mm/memory-hotplug.rst
> > @@ -31,7 +31,6 @@ be changed often.
> >      6.1 Memory offline and ZONE_MOVABLE
> >      6.2. How to offline memory
> >    7. Physical memory remove
> > -  8. Memory hotplug event notifier
> >    9. Future Work List
> 
> That leaves a gap in the numbering here.
> 
> In general, the best solution to this sort of issue is to take the TOC out
> entirely and let Sphinx worry about generating it.  People tend not to
> think about updating the TOC when they make changes elsewhere, so it often
> goes out of sync with the rest of the document anyway.
> 
> I'll apply these, but please feel free to send a patch to fix this up.

Sure, below
 
> Thanks,
> 
> jon
> 
