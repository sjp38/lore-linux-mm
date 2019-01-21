Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 84E9E8E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 13:24:21 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id p65-v6so5300264ljb.16
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 10:24:21 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k14-v6sor7713694lji.4.2019.01.21.10.24.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 21 Jan 2019 10:24:19 -0800 (PST)
Date: Mon, 21 Jan 2019 21:24:16 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: + mm-thp-always-specify-disabled-vmas-as-nh-in-smaps.patch added
 to -mm tree
Message-ID: <20190121182416.GB2332@uranus.lan>
References: <alpine.DEB.2.21.1812240058060.114867@chino.kir.corp.google.com>
 <20181224091731.GB16738@dhcp22.suse.cz>
 <20181227111114.5tvvkddyp7cytzeb@kshutemo-mobl1>
 <20181227213100.aeee730c1f9ec5cb11de39a3@linux-foundation.org>
 <20181228081847.GP16738@dhcp22.suse.cz>
 <00ec4644-70c2-4bd1-ec3f-b994fa0669e8@suse.cz>
 <20190115063202.GA13744@rapoport-lnx>
 <20190121102144.GP4087@dhcp22.suse.cz>
 <20190121180029.GA2332@uranus.lan>
 <20190121181824.GW4087@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190121181824.GW4087@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mike Rapoport <rppt@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, David Rientjes <rientjes@google.com>, kirill.shutemov@linux.intel.com, adobriyan@gmail.com, Linux API <linux-api@vger.kernel.org>, Andrei Vagin <avagin@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Linux-MM layout <linux-mm@kvack.org>

On Mon, Jan 21, 2019 at 07:18:24PM +0100, Michal Hocko wrote:
> > > 
> > > So can we make a decision on this finally please?
> > 
> > As to me David's userspace application could use /proc/$pid/status
> > to fetch precise THP state. And the patch in mm queue simply breaks
> > others userspace thus should be reverted.
> 
> 7635d9cbe832 ("mm, thp, proc: report THP eligibility for each vma") will
> provide even more detailed information because it displays THP
> eligibility per VMA so you do not have to check all other conditions
> that control THP.

Thus the only thing we need is to wait for David's reply if he can
update his application to use the THPeligible flag and drop the
patch from mm queue
