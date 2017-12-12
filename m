Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9FE8A6B0033
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 16:28:05 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id b11so844871itj.0
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 13:28:05 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t80sor71280ioi.142.2017.12.12.13.28.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Dec 2017 13:28:04 -0800 (PST)
Date: Tue, 12 Dec 2017 13:28:01 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] mm, mmu_notifier: annotate mmu notifiers with
 blockable invalidate callbacks
In-Reply-To: <20171212200542.GJ5848@hpe.com>
Message-ID: <alpine.DEB.2.10.1712121326280.134224@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1712111409090.196232@chino.kir.corp.google.com> <20171212200542.GJ5848@hpe.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dimitri Sivanich <sivanich@hpe.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Oded Gabbay <oded.gabbay@gmail.com>, Alex Deucher <alexander.deucher@amd.com>, =?UTF-8?Q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>, David Airlie <airlied@linux.ie>, Joerg Roedel <joro@8bytes.org>, Doug Ledford <dledford@redhat.com>, Jani Nikula <jani.nikula@linux.intel.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Sean Hefty <sean.hefty@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, =?UTF-8?Q?J=C3=A9r=C3=B4me_Glisse?= <jglisse@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?Q?Radim_Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 12 Dec 2017, Dimitri Sivanich wrote:

> > --- a/drivers/misc/sgi-gru/grutlbpurge.c
> > +++ b/drivers/misc/sgi-gru/grutlbpurge.c
> > @@ -298,6 +298,7 @@ struct gru_mm_struct *gru_register_mmu_notifier(void)
> >  			return ERR_PTR(-ENOMEM);
> >  		STAT(gms_alloc);
> >  		spin_lock_init(&gms->ms_asid_lock);
> > +		gms->ms_notifier.flags = 0;
> >  		gms->ms_notifier.ops = &gru_mmuops;
> >  		atomic_set(&gms->ms_refcnt, 1);
> >  		init_waitqueue_head(&gms->ms_wait_queue);
> > diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
> 
> There is a kzalloc() just above this:
> 	gms = kzalloc(sizeof(*gms), GFP_KERNEL);
> 
> Is that not sufficient to clear the 'flags' field?
> 

Absolutely, but whether it is better to explicitly document that the mmu 
notifier has cleared flags, i.e. there are no blockable callbacks, is 
another story.  I can change it if preferred.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
