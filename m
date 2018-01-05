Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 80934280265
	for <linux-mm@kvack.org>; Fri,  5 Jan 2018 03:46:34 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id 3so2772298plv.17
        for <linux-mm@kvack.org>; Fri, 05 Jan 2018 00:46:34 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f75si3757698pfj.228.2018.01.05.00.46.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 05 Jan 2018 00:46:33 -0800 (PST)
Date: Fri, 5 Jan 2018 09:46:31 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mmotm 2018-01-04-16-19 uploaded
Message-ID: <20180105084631.GG2801@dhcp22.suse.cz>
References: <5a4ec4bc.u5I/HzCSE6TLVn02%akpm@linux-foundation.org>
 <7e35e16a-d71c-2ec8-03ed-b07c2af562f8@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7e35e16a-d71c-2ec8-03ed-b07c2af562f8@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, broonie@kernel.org

On Fri 05-01-18 12:13:17, Anshuman Khandual wrote:
> On 01/05/2018 05:50 AM, akpm@linux-foundation.org wrote:
> > The mm-of-the-moment snapshot 2018-01-04-16-19 has been uploaded to
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
> > You will need quilt to apply these patches to the latest Linus release (4.x
> > or 4.x-rcY).  The series file is in broken-out.tar.gz and is duplicated in
> > http://ozlabs.org/~akpm/mmotm/series
> > 
> > The file broken-out.tar.gz contains two datestamp files: .DATE and
> > .DATE-yyyy-mm-dd-hh-mm-ss.  Both contain the string yyyy-mm-dd-hh-mm-ss,
> > followed by the base kernel version against which this patch series is to
> > be applied.
> > 
> > This tree is partially included in linux-next.  To see which patches are
> > included in linux-next, consult the `series' file.  Only the patches
> > within the #NEXT_PATCHES_START/#NEXT_PATCHES_END markers are included in
> > linux-next.
> > 
> > A git tree which contains the memory management portion of this tree is
> > maintained at git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
> 
> Seems like this latest snapshot mmotm-2018-01-04-16-19 has not been
> updated in this git tree. I could not fetch not it shows up in the
> http link below.
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git

I will update the tree today (WIP). This is not a fully automated
process and Andrew pushed his tree during my night ;) So be patient
please. My tree is non-rebasing which means I cannot just throw the old
tree away and regenerate it from scratch.

> The last one mmotm-2017-12-22-17-55 seems to have some regression on
> powerpc with respect to ELF loading of binaries (see below). Seems to
> be related to recent MAP_FIXED_SAFE (or MAP_FIXED_NOREPLACE as seen
> now in the code). IIUC (have not been following the series last month)
> MAP_FIXED_NOREPLACE will fail an allocation request if the hint address
> cannot be reserve instead of changing existing mappings.

Correct

> Is it possible
> that ELF loading needs to be fixed at a higher level to deal with these
> new possible mmap() failures because of MAP_FIXED_NOREPLACE ?

Could you give us more information about the failure please. Debugging
patch from http://lkml.kernel.org/r/20171218091302.GL16951@dhcp22.suse.cz
should help to see what is the clashing VMA.

Thanks
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
