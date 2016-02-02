Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id DD32C6B0005
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 18:03:26 -0500 (EST)
Received: by mail-qg0-f44.google.com with SMTP id b35so3206525qge.0
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 15:03:26 -0800 (PST)
Received: from mail-qg0-x231.google.com (mail-qg0-x231.google.com. [2607:f8b0:400d:c04::231])
        by mx.google.com with ESMTPS id z2si3148336qkg.60.2016.02.02.15.03.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Feb 2016 15:03:26 -0800 (PST)
Received: by mail-qg0-x231.google.com with SMTP id e32so3112618qgf.3
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 15:03:26 -0800 (PST)
Date: Wed, 3 Feb 2016 00:03:16 +0100
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [LSF/MM ATTEND] HMM (heterogeneous memory manager) and GPU
Message-ID: <20160202230314.GA5183@gmail.com>
References: <20160128175536.GA20797@gmail.com>
 <87bn805t8l.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <87bn805t8l.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: lsf-pc@lists.linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Feb 01, 2016 at 09:16:02PM +0530, Aneesh Kumar K.V wrote:
> Jerome Glisse <j.glisse@gmail.com> writes:
> 
> > Hi,
> >
> > I would like to attend LSF/MM this year to discuss about HMM
> > (Heterogeneous Memory Manager) and more generaly all topics
> > related to GPU and heterogeneous memory architecture (including
> > persistent memory).
> >
> > I want to discuss how to move forward with HMM merging and i
> > hope that by MM summit time i will be able to share more
> > informations publicly on devices which rely on HMM.
> >
> 
> I mentioned in my request to attend mail, I would like to attend this
> discussion. I am wondering whether we can split the series further to
> mmu_notifier bits and then the page table mirroring bits. Can the mmu notifier
> changes go in early so that we can merge the page table mirroring later ?

Well the mmu_notifier bit can be upstream on their own but they would
not useful. Maybe on KVM side i need to investigate.


> Can be page table mirroring bits be built as a kernel module ?

Well i am not sure this is a good idea. Memory migration requires to
hook up into page fault code path and it relies on the mirrored page
table to service fault on memory that is migrated.

Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
