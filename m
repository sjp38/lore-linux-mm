Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E08166B0033
	for <linux-mm@kvack.org>; Sat, 20 Jan 2018 00:25:30 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id f8so454221wmi.9
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 21:25:30 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id r66si1840258wmg.252.2018.01.19.21.25.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jan 2018 21:25:29 -0800 (PST)
Date: Sat, 20 Jan 2018 05:24:32 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [mm 4.15-rc8] Random oopses under memory pressure.
Message-ID: <20180120052432.GN13338@ZenIV.linux.org.uk>
References: <d8347087-18a6-1709-8aa8-3c6f2d16aa94@linux.intel.com>
 <20180118145830.GA6406@redhat.com>
 <20180118165629.kpdkezarsf4qymnw@node.shutemov.name>
 <CA+55aFy43ypm0QvA5SqNR4O0ZJETbkR3NDR=dnSdvejc_nmSJQ@mail.gmail.com>
 <20180118234955.nlo55rw2qsfnavfm@node.shutemov.name>
 <20180119125503.GA2897@bombadil.infradead.org>
 <CA+55aFwWCeFrhN+WJDD8u9nqBzmvknXk428Q0dVwwXAvwhg_-w@mail.gmail.com>
 <20180119221243.GL13338@ZenIV.linux.org.uk>
 <CA+55aFw4mw32Mu0_+cgKAzxCNvDW1VPcESv7CyajexfDfMju1A@mail.gmail.com>
 <20180120020237.GM13338@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180120020237.GM13338@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Tony Luck <tony.luck@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, "hillf.zj" <hillf.zj@alibaba-inc.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>

On Sat, Jan 20, 2018 at 02:02:37AM +0000, Al Viro wrote:

> Note that those sizes are rather sensitive to lockdep, spinlock debugging, etc.

That they certainly are: on one of the testing .config I'm using it gave this:
   1104 sizeof struct page = 56
     81 sizeof struct cpufreq_frequency_table = 12
     32 sizeof struct Indirect = 24
      7 sizeof struct zone = 1400
      7 sizeof struct hstate = 152
      6 sizeof struct lock_class = 336
      6 sizeof struct hpet_dev = 152
      6 sizeof struct ext4_extent = 12
      4 sizeof struct ext4_extent_idx = 12
      3 sizeof struct mbox_chan = 456
      2 sizeof struct strip_zone = 24
      2 sizeof struct kobj_attribute = 48
      2 sizeof struct kernel_param = 40
      2 sizeof struct exception_table_entry = 12
      1 sizeof struct vif_device = 104
      1 sizeof struct unixware_slice = 12
      1 sizeof struct svc_pool = 152
      1 sizeof struct srcu_node = 152
      1 sizeof struct r5worker_group = 56
      1 sizeof struct pebs_record_core = 144
      1 sizeof struct netdev_queue = 384
      1 sizeof struct mirror = 40
      1 sizeof struct mif_device = 56
      1 sizeof struct e1000_tx_ring = 48
      1 sizeof struct dx_frame = 24
      1 sizeof struct bts_record = 24
      1 sizeof struct ata_device = 2560
      1 sizeof struct acpi_processor_cx = 52

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
