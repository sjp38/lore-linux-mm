Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id A29526B002B
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 18:54:03 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id e20so439954dak.14
        for <linux-mm@kvack.org>; Wed, 12 Dec 2012 15:54:02 -0800 (PST)
Date: Wed, 12 Dec 2012 15:53:58 -0800
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [RFC PATCH 01/11] Add hotplug.h for hotplug framework
Message-ID: <20121212235358.GA22764@kroah.com>
References: <1355354243-18657-1-git-send-email-toshi.kani@hp.com>
 <1355354243-18657-2-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1355354243-18657-2-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: rjw@sisk.pl, lenb@kernel.org, akpm@linux-foundation.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, bhelgaas@google.com, isimatu.yasuaki@jp.fujitsu.com, jiang.liu@huawei.com, wency@cn.fujitsu.com, guohanjun@huawei.com, yinghai@kernel.org, srivatsa.bhat@linux.vnet.ibm.com

On Wed, Dec 12, 2012 at 04:17:13PM -0700, Toshi Kani wrote:
> Added include/linux/hotplug.h, which defines the hotplug framework
> interfaces used by the framework itself and handlers.

No, please name this properly, _everything_ is hotpluggable these days,
and unless you want the whole kernel and all busses and devices to use
this, then it needs to be named much better than this, sorry.

We went through this same issue over 10 years ago, please, let's learn
from our mistakes and not do it again.

> +/* Add Validate order values */
> +#define HP_ACPI_BUS_ADD_VALIDATE_ORDER		0	/* must be first */

This is really ACPI specific, so why not just put it under include/acpi/
instead?

And note, PPC and other arches probably do this already (s390?) so to
exclude them from the beginning would not be a good idea.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
