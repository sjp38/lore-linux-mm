Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5E85E6B0253
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 16:46:55 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id e41so16400655itd.5
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 13:46:55 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a124sor3556175itg.111.2017.12.15.13.46.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Dec 2017 13:46:54 -0800 (PST)
Date: Fri, 15 Dec 2017 13:46:50 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2 2/2] mm, oom: avoid reaping only for mm's with blockable
 invalidate callbacks
In-Reply-To: <20171215163534.GB16951@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1712151343430.168988@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1712111409090.196232@chino.kir.corp.google.com> <alpine.DEB.2.10.1712141329500.74052@chino.kir.corp.google.com> <alpine.DEB.2.10.1712141330120.74052@chino.kir.corp.google.com> <20171215163534.GB16951@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Oded Gabbay <oded.gabbay@gmail.com>, Alex Deucher <alexander.deucher@amd.com>, =?UTF-8?Q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>, David Airlie <airlied@linux.ie>, Joerg Roedel <joro@8bytes.org>, Doug Ledford <dledford@redhat.com>, Jani Nikula <jani.nikula@linux.intel.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Sean Hefty <sean.hefty@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, =?UTF-8?Q?J=C3=A9r=C3=B4me_Glisse?= <jglisse@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?Q?Radim_Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 15 Dec 2017, Michal Hocko wrote:

> > This uses the new annotation to determine if an mm has mmu notifiers with
> > blockable invalidate range callbacks to avoid oom reaping.  Otherwise, the
> > callbacks are used around unmap_page_range().
> 
> Do you have any example where this helped? KVM guest oom killed I guess?
> 

KVM is the most significant one that we are interested in, but haven't had 
sufficient time to quantify how much of an impact this has other than to 
say it will certainly be non-zero.

The motivation was more to exclude mmu notifiers that have a reason to be 
excluded rather than a blanket exemption to make the oom reaper more 
robust.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
