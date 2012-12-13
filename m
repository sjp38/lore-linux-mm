Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 032DA6B002B
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 23:11:47 -0500 (EST)
Message-ID: <1355371365.18964.89.camel@misato.fc.hp.com>
Subject: Re: [RFC PATCH 02/11] drivers/base: Add hotplug framework code
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 12 Dec 2012 21:02:45 -0700
In-Reply-To: <20121212235418.GB22764@kroah.com>
References: <1355354243-18657-1-git-send-email-toshi.kani@hp.com>
	 <1355354243-18657-3-git-send-email-toshi.kani@hp.com>
	 <20121212235418.GB22764@kroah.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: rjw@sisk.pl, lenb@kernel.org, akpm@linux-foundation.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, bhelgaas@google.com, isimatu.yasuaki@jp.fujitsu.com, jiang.liu@huawei.com, wency@cn.fujitsu.com, guohanjun@huawei.com, yinghai@kernel.org, srivatsa.bhat@linux.vnet.ibm.com

On Wed, 2012-12-12 at 15:54 -0800, Greg KH wrote:
> On Wed, Dec 12, 2012 at 04:17:14PM -0700, Toshi Kani wrote:
> > Added hotplug.c, which is the hotplug framework code.
> 
> Again, better naming please.

Yes, I will change it to be more specific, something like
"sys_hotplug.c".

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
