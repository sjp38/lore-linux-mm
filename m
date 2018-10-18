Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id AE8BE6B0006
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 17:05:34 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id s123-v6so32467537qkf.12
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 14:05:34 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i90-v6si8422469qkh.253.2018.10.18.14.05.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Oct 2018 14:05:33 -0700 (PDT)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: Problems with VM_MIXEDMAP removal from /proc/<pid>/smaps
References: <20181002100531.GC4135@quack2.suse.cz>
	<20181002121039.GA3274@linux-x5ow.site>
	<20181002142959.GD9127@quack2.suse.cz>
	<x49h8hkfhk9.fsf@segfault.boston.devel.redhat.com>
	<20181018002510.GC6311@dastard>
Date: Thu, 18 Oct 2018 17:05:30 -0400
In-Reply-To: <20181018002510.GC6311@dastard> (Dave Chinner's message of "Thu,
	18 Oct 2018 11:25:10 +1100")
Message-ID: <x49woqfq82t.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, Johannes Thumshirn <jthumshirn@suse.de>, Dan Williams <dan.j.williams@intel.com>, Dave Jiang <dave.jiang@intel.com>, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-api@vger.kernel.org

Dave,

Thanks for the detailed response!  I hadn't considered the NOVA use case
at all.

Cheers,
Jeff
