Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9FF6D6B0055
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 17:09:41 -0400 (EDT)
Date: Fri, 25 Sep 2009 23:09:42 +0200
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: No more bits in vm_area_struct's vm_flags.
Message-ID: <20090925210942.GB29634@8bytes.org>
References: <4AB9A0D6.1090004@crca.org.au> <20090924100518.78df6b93.kamezawa.hiroyu@jp.fujitsu.com> <4ABC80B0.5010100@crca.org.au> <20090925174009.79778649.kamezawa.hiroyu@jp.fujitsu.com> <4ABC83E2.7050300@crca.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4ABC83E2.7050300@crca.org.au>
Sender: owner-linux-mm@kvack.org
To: Nigel Cunningham <ncunningham@crca.org.au>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Sep 25, 2009 at 06:48:34PM +1000, Nigel Cunningham wrote:
> Hi.
> 
> KAMEZAWA Hiroyuki wrote:
> > On Fri, 25 Sep 2009 18:34:56 +1000
> > Nigel Cunningham <ncunningham@crca.org.au> wrote:
> > 
> >> Hi.
> >>
> >> KAMEZAWA Hiroyuki wrote:
> >>>> I have some code in TuxOnIce that needs a bit too (explicitly mark the
> >>>> VMA as needing to be atomically copied, for GEM objects), and am not
> >>>> sure what the canonical way to proceed is. Should a new unsigned long be
> >>>> added? The difficulty I see with that is that my flag was used in
> >>>> shmem_file_setup's flags parameter (drm_gem_object_alloc), so that
> >>>> function would need an extra parameter too..
> >>> Hmm, how about adding vma->vm_flags2 ?
> >> The difficulty there is that some functions pass these flags as arguments.
> >>
> > Ah yes. But I wonder some special flags, which is rarey used, can be moved
> > to vm_flags2...

But please don't call it vm_flags2. I think its better to partition the
existing flags by there purpose somehow hand give the flags fields
appropriate names which express that purpose.

	Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
