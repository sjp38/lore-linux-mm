Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id EA6556B0038
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 08:47:01 -0400 (EDT)
Received: by igbkq10 with SMTP id kq10so77652180igb.0
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 05:47:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id bg8si5311575pdb.233.2015.09.08.05.47.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Sep 2015 05:47:01 -0700 (PDT)
Date: Tue, 8 Sep 2015 13:46:52 +0100
From: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [Qemu-devel] [PATCH 19/23] userfaultfd: activate syscall
Message-ID: <20150908124652.GK2246@work-vm>
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
 <1431624680-20153-20-git-send-email-aarcange@redhat.com>
 <20150811100728.GB4587@in.ibm.com>
 <20150811134826.GI4520@redhat.com>
 <20150812052346.GC4587@in.ibm.com>
 <1441692486.14597.17.camel@ellerman.id.au>
 <20150908063948.GB678@in.ibm.com>
 <20150908085946.GC2246@work-vm>
 <20150908095915.GC678@in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150908095915.GC678@in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bharata B Rao <bharata@linux.vnet.ibm.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-api@vger.kernel.org, zhang.zhanghailiang@huawei.com, Pavel Emelyanov <xemul@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Andres Lagar-Cavilla <andreslc@google.com>, Mel Gorman <mgorman@suse.de>, Paolo Bonzini <pbonzini@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Andy Lutomirski <luto@amacapital.net>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Feiner <pfeiner@google.com>, linuxppc-dev@lists.ozlabs.org

* Bharata B Rao (bharata@linux.vnet.ibm.com) wrote:
> On Tue, Sep 08, 2015 at 09:59:47AM +0100, Dr. David Alan Gilbert wrote:
> > * Bharata B Rao (bharata@linux.vnet.ibm.com) wrote:
> > > In fact I had successfully done postcopy migration of sPAPR guest with
> > > this setup.
> > 
> > Interesting - I'd not got that far myself on power; I was hitting a problem
> > loading htab ( htab_load() bad index 2113929216 (14848+0 entries) in htab stream (htab_shift=25) )
> > 
> > Did you have to make any changes to the qemu code to get that happy?
> 
> I should have mentioned that I tried only QEMU driven migration within
> the same host using wp3-postcopy branch of your tree. I don't see the
> above issue.
> 
> (qemu) info migrate
> capabilities: xbzrle: off rdma-pin-all: off auto-converge: off zero-blocks: off compress: off x-postcopy-ram: on 
> Migration status: completed
> total time: 39432 milliseconds
> downtime: 162 milliseconds
> setup: 14 milliseconds
> transferred ram: 1297209 kbytes
> throughput: 270.72 mbps
> remaining ram: 0 kbytes
> total ram: 4194560 kbytes
> duplicate: 734015 pages
> skipped: 0 pages
> normal: 318469 pages
> normal bytes: 1273876 kbytes
> dirty sync count: 4
> 
> I will try migration between different hosts soon and check.

I hit that on the same host; are you sure you've switched into postcopy mode;
i.e. issued a migrate_start_postcopy before the end of migration?

(My current world I have working on x86-64 and I've also tested reasonably well
on aarch64, and get to that htab problem on Power).

Dave

> 
> Regards,
> Bharata.
> 
--
Dr. David Alan Gilbert / dgilbert@redhat.com / Manchester, UK

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
