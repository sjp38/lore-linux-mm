Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 2F50A6B0071
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 10:19:20 -0500 (EST)
Date: Thu, 11 Feb 2010 23:16:51 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH v2] Make VM_MAX_READAHEAD a kernel parameter
Message-ID: <20100211151651.GA8753@localhost>
References: <201002091659.27037.knikanth@suse.de> <201002111546.35036.knikanth@suse.de> <d24465cb1002110315x4af18888na55aa8d61478e094@mail.gmail.com> <201002111715.04411.knikanth@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201002111715.04411.knikanth@suse.de>
Sender: owner-linux-mm@kvack.org
To: Nikanth Karthikesan <knikanth@suse.de>
Cc: Ankit Jain <radical@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Jens Axboe <jens.axboe@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Nikanth,

> From: Nikanth Karthikesan <knikanth@suse.de>
> 
> Add new kernel parameter "readahead", which would be used instead of the
> value of VM_MAX_READAHEAD. If the parameter is not specified, the default
> of 128kb would be used.

The patch looks good to me, though it conflicts with my patches.
Do you mind me including a modified version in my readahead patchset?

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
