Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id A726D8E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 13:18:29 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id i55so8154291ede.14
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 10:18:29 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d1si1964980edr.19.2019.01.21.10.18.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 10:18:28 -0800 (PST)
Date: Mon, 21 Jan 2019 19:18:24 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: + mm-thp-always-specify-disabled-vmas-as-nh-in-smaps.patch added
 to -mm tree
Message-ID: <20190121181824.GW4087@dhcp22.suse.cz>
References: <20181224080426.GC9063@dhcp22.suse.cz>
 <alpine.DEB.2.21.1812240058060.114867@chino.kir.corp.google.com>
 <20181224091731.GB16738@dhcp22.suse.cz>
 <20181227111114.5tvvkddyp7cytzeb@kshutemo-mobl1>
 <20181227213100.aeee730c1f9ec5cb11de39a3@linux-foundation.org>
 <20181228081847.GP16738@dhcp22.suse.cz>
 <00ec4644-70c2-4bd1-ec3f-b994fa0669e8@suse.cz>
 <20190115063202.GA13744@rapoport-lnx>
 <20190121102144.GP4087@dhcp22.suse.cz>
 <20190121180029.GA2332@uranus.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190121180029.GA2332@uranus.lan>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Mike Rapoport <rppt@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, David Rientjes <rientjes@google.com>, kirill.shutemov@linux.intel.com, adobriyan@gmail.com, Linux API <linux-api@vger.kernel.org>, Andrei Vagin <avagin@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Linux-MM layout <linux-mm@kvack.org>

On Mon 21-01-19 21:00:29, Cyrill Gorcunov wrote:
> On Mon, Jan 21, 2019 at 11:21:44AM +0100, Michal Hocko wrote:
> ...
> > > 
> > > The patch from David obviously breaks CRIU, and I can't see a nice solution
> > > that will work for everybody.
> > > 
> > > Of course we could add something like 'NH' to /proc/pid/smaps so that 'nh'
> > > will work as David's userspace is expecting and 'NH' will represent the
> > > state of VmFlags. This is hackish and ugly, though.
> > > 
> > > In any case, if David's patch is not reverted CRIU needs some way to know
> > > if VMA has VM_NOHUGEPAGE set.
> > 
> > Hmm, there doesn't seem to be any follow up here and the patch is still
> > in the mmotm tree AFAICS in mainline-urgent section. I thought it was
> > clarified that the patch will break an existing userspace that relies on
> > the documented semantic.
> > 
> > While it is unfortunate that the use case mentioned by David got broken
> > we have provided a long term sustainable which is much better than
> > relying on an undocumented side effect of the prctl implementation at
> > the time.
> > 
> > So can we make a decision on this finally please?
> 
> As to me David's userspace application could use /proc/$pid/status
> to fetch precise THP state. And the patch in mm queue simply breaks
> others userspace thus should be reverted.

7635d9cbe832 ("mm, thp, proc: report THP eligibility for each vma") will
provide even more detailed information because it displays THP
eligibility per VMA so you do not have to check all other conditions
that control THP.

-- 
Michal Hocko
SUSE Labs
