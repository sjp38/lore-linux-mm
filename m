Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9AC306B0006
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 18:56:44 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id h21so3716907qtm.22
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 15:56:44 -0800 (PST)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id b57si1166625qta.194.2018.02.22.15.56.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Feb 2018 15:56:43 -0800 (PST)
Date: Fri, 23 Feb 2018 07:56:39 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH v2 1/3] mm/sparse: Add a static variable
 nr_present_sections
Message-ID: <20180222235639.GD693@localhost.localdomain>
References: <20180222091130.32165-1-bhe@redhat.com>
 <20180222091130.32165-2-bhe@redhat.com>
 <20180222132441.51a8eae9e9656a82a2161070@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180222132441.51a8eae9e9656a82a2161070@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, dave.hansen@intel.com, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, tglx@linutronix.de

On 02/22/18 at 01:24pm, Andrew Morton wrote:
> On Thu, 22 Feb 2018 17:11:28 +0800 Baoquan He <bhe@redhat.com> wrote:
> 
> > It's used to record how many memory sections are marked as present
> > during system boot up, and will be used in the later patch.
> > 
> > --- a/mm/sparse.c
> > +++ b/mm/sparse.c
> > @@ -202,6 +202,7 @@ static inline int next_present_section_nr(int section_nr)
> >  	      (section_nr <= __highest_present_section_nr));	\
> >  	     section_nr = next_present_section_nr(section_nr))
> >  
> > +static int nr_present_sections;
> 
> I think this could be __initdata.
> 
> A nice comment explaining why it exists would be nice.

Thanks, I will update as you suggested.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
