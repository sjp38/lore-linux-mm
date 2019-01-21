Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8AAB78E0008
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 13:00:33 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id g92-v6so5160382ljg.23
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 10:00:33 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o28sor3415146lfd.61.2019.01.21.10.00.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 21 Jan 2019 10:00:31 -0800 (PST)
Date: Mon, 21 Jan 2019 21:00:29 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: + mm-thp-always-specify-disabled-vmas-as-nh-in-smaps.patch added
 to -mm tree
Message-ID: <20190121180029.GA2332@uranus.lan>
References: <alpine.DEB.2.21.1812211419320.219499@chino.kir.corp.google.com>
 <20181224080426.GC9063@dhcp22.suse.cz>
 <alpine.DEB.2.21.1812240058060.114867@chino.kir.corp.google.com>
 <20181224091731.GB16738@dhcp22.suse.cz>
 <20181227111114.5tvvkddyp7cytzeb@kshutemo-mobl1>
 <20181227213100.aeee730c1f9ec5cb11de39a3@linux-foundation.org>
 <20181228081847.GP16738@dhcp22.suse.cz>
 <00ec4644-70c2-4bd1-ec3f-b994fa0669e8@suse.cz>
 <20190115063202.GA13744@rapoport-lnx>
 <20190121102144.GP4087@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190121102144.GP4087@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mike Rapoport <rppt@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, David Rientjes <rientjes@google.com>, kirill.shutemov@linux.intel.com, adobriyan@gmail.com, Linux API <linux-api@vger.kernel.org>, Andrei Vagin <avagin@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Linux-MM layout <linux-mm@kvack.org>

On Mon, Jan 21, 2019 at 11:21:44AM +0100, Michal Hocko wrote:
...
> > 
> > The patch from David obviously breaks CRIU, and I can't see a nice solution
> > that will work for everybody.
> > 
> > Of course we could add something like 'NH' to /proc/pid/smaps so that 'nh'
> > will work as David's userspace is expecting and 'NH' will represent the
> > state of VmFlags. This is hackish and ugly, though.
> > 
> > In any case, if David's patch is not reverted CRIU needs some way to know
> > if VMA has VM_NOHUGEPAGE set.
> 
> Hmm, there doesn't seem to be any follow up here and the patch is still
> in the mmotm tree AFAICS in mainline-urgent section. I thought it was
> clarified that the patch will break an existing userspace that relies on
> the documented semantic.
> 
> While it is unfortunate that the use case mentioned by David got broken
> we have provided a long term sustainable which is much better than
> relying on an undocumented side effect of the prctl implementation at
> the time.
> 
> So can we make a decision on this finally please?

As to me David's userspace application could use /proc/$pid/status
to fetch precise THP state. And the patch in mm queue simply breaks
others userspace thus should be reverted.
