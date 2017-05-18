Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 66492831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 06:19:47 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id d127so8066137wmf.15
        for <linux-mm@kvack.org>; Thu, 18 May 2017 03:19:47 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id k47si5009034wre.305.2017.05.18.03.19.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 May 2017 03:19:46 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id v4so10114709wmb.2
        for <linux-mm@kvack.org>; Thu, 18 May 2017 03:19:45 -0700 (PDT)
Date: Thu, 18 May 2017 13:09:37 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] Patch for remapping pages around the fault page
Message-ID: <20170518100937.uk53l53ulvvqz2q4@node.shutemov.name>
References: <CAC2c7Jts5uZOLXVi9N7xYXxxycv9xM1TBxcC3nMyn0NL-O+spw@mail.gmail.com>
 <20170518055333.GC24445@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170518055333.GC24445@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Sarunya Pumma <sarunya@vt.edu>, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, jack@suse.cz, ross.zwisler@linux.intel.com, mhocko@suse.com, aneesh.kumar@linux.vnet.ibm.com, lstoakes@gmail.com, dave.jiang@intel.com, linux-mm@kvack.org

On Thu, May 18, 2017 at 08:53:33AM +0300, Mike Rapoport wrote:
> Hello,
> 
> On Tue, May 16, 2017 at 12:16:00PM -0400, Sarunya Pumma wrote:
> > After the fault handler performs the __do_fault function to read a fault
> > page when a page fault occurs, it does not map other pages that have been
> > read together with the fault page. This can cause a number of minor page
> > faults to be large. Therefore, this patch is developed to remap pages
> > around the fault page by aiming to map the pages that have been read
> > with the fault page.
> 
> [...] 
>  
> > Thank you very much for your time for reviewing the patch.
> > 
> > Signed-off-by: Sarunya Pumma <sarunya@vt.edu>
> > ---
> >  include/linux/mm.h |  2 ++
> >  kernel/sysctl.c    |  8 +++++
> >  mm/memory.c        | 90
> > ++++++++++++++++++++++++++++++++++++++++++++++++++++++
> >  3 files changed, 100 insertions(+)
> 
> The patch is completely unreadable :(
> Please use a mail client that does not break whitespace, e.g 'git
> send-email'

And I would like to see performance numbers, please.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
