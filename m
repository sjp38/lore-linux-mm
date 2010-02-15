Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 478C66B007B
	for <linux-mm@kvack.org>; Sun, 14 Feb 2010 23:35:41 -0500 (EST)
From: Nikanth Karthikesan <knikanth@suse.de>
Subject: Re: [PATCH v2] Make VM_MAX_READAHEAD a kernel parameter
Date: Mon, 15 Feb 2010 10:05:05 +0530
References: <201002091659.27037.knikanth@suse.de> <201002111715.04411.knikanth@suse.de> <20100211151651.GA8753@localhost>
In-Reply-To: <20100211151651.GA8753@localhost>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201002151005.05923.knikanth@suse.de>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Ankit Jain <radical@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Jens Axboe <jens.axboe@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thursday 11 February 2010 20:46:51 Wu Fengguang wrote:
> Nikanth,
> 
> > From: Nikanth Karthikesan <knikanth@suse.de>
> >
> > Add new kernel parameter "readahead", which would be used instead of the
> > value of VM_MAX_READAHEAD. If the parameter is not specified, the default
> > of 128kb would be used.
> 
> The patch looks good to me, though it conflicts with my patches.
> Do you mind me including a modified version in my readahead patchset?
> 

Sure, go ahead.

Thanks
Nikanth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
