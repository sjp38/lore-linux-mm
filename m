Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0F1F76B0031
	for <linux-mm@kvack.org>; Tue, 17 Jun 2014 14:39:08 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id et14so4695965pad.35
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 11:39:08 -0700 (PDT)
Received: from mail-pb0-x235.google.com (mail-pb0-x235.google.com [2607:f8b0:400e:c01::235])
        by mx.google.com with ESMTPS id qy3si9386724pab.224.2014.06.17.11.39.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 17 Jun 2014 11:39:08 -0700 (PDT)
Received: by mail-pb0-f53.google.com with SMTP id uo5so5702445pbc.12
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 11:39:07 -0700 (PDT)
Message-ID: <53A08B47.3010701@gmail.com>
Date: Tue, 17 Jun 2014 21:39:03 +0300
From: Boaz Harrosh <openosd@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v7 00/22] Support ext4 on NV-DIMMs
References: <cover.1395591795.git.matthew.r.wilcox@intel.com> <53A084E3.6080103@gmail.com> <20140617181925.GF12025@linux.intel.com>
In-Reply-To: <20140617181925.GF12025@linux.intel.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 06/17/2014 09:19 PM, Matthew Wilcox wrote:
> On Tue, Jun 17, 2014 at 09:11:47PM +0300, Boaz Harrosh wrote:
> 
> https://github.com/01org/prd should sort you out with both a git tree
> and a new block driver.  You'll need to tell it manually what address
> range to use.  I'm using it against regular DIMMs, and this works pretty
> well for me since my BIOS doesn't zero DRAM on reset.
> 

God Yes exactly my missing link, Thanks. How I failed to find it?

Yes for us too, BIOS doesn't zero DRAM and we can use it with using
memmap= on kernel boot.

Please include above link in new patchset and Documentation. Just
to make the overall picture clearer. BTW what prevents from submitting
this prd driver upstream right now? there are devices out there that will
need it no? Even for something simple and very smart as putting my
ext4 or xfs journal device on nv-dimm, no?
The "manually address range to use" is fine in my book. A user-mode
udev rule can then be used to cover the gap from sbus or acpi to prd.

Hey actually this tree has everything I need. thanks man
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
