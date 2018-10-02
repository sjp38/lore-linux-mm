Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id DBC3B6B0003
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 06:05:33 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id g36-v6so983824edb.3
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 03:05:33 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l12-v6si577192edj.314.2018.10.02.03.05.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Oct 2018 03:05:32 -0700 (PDT)
Date: Tue, 2 Oct 2018 12:05:31 +0200
From: Jan Kara <jack@suse.cz>
Subject: Problems with VM_MIXEDMAP removal from /proc/<pid>/smaps
Message-ID: <20181002100531.GC4135@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="YZ5djTAD1cGYuMQK"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, Dave Jiang <dave.jiang@intel.com>
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, jthumshirn@suse.de


--YZ5djTAD1cGYuMQK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello,

commit e1fb4a086495 "dax: remove VM_MIXEDMAP for fsdax and device dax" has
removed VM_MIXEDMAP flag from DAX VMAs. Now our testing shows that in the
mean time certain customer of ours started poking into /proc/<pid>/smaps
and looks at VMA flags there and if VM_MIXEDMAP is missing among the VMA
flags, the application just fails to start complaining that DAX support is
missing in the kernel. The question now is how do we go about this?

Strictly speaking, this is a userspace visible regression (as much as I
think that application poking into VMA flags at this level is just too
bold). Is there any precedens in handling similar issues with smaps which
really exposes a lot of information that is dependent on kernel
implementation details?

I have attached a patch that is an obvious "fix" for the issue - just fake
VM_MIXEDMAP flag in smaps. But I'm open to other suggestions...

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--YZ5djTAD1cGYuMQK
Content-Type: text/x-patch; charset=us-ascii
Content-Disposition: attachment; filename="0001-proc-Show-DAX-mappings-as-having-VM_MIXEDMAP-flag.patch"


--YZ5djTAD1cGYuMQK--
