Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f41.google.com (mail-qa0-f41.google.com [209.85.216.41])
	by kanga.kvack.org (Postfix) with ESMTP id 90E096B0031
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 14:40:18 -0500 (EST)
Received: by mail-qa0-f41.google.com with SMTP id w5so4543429qac.14
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 11:40:18 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id x4si11541112qad.124.2014.01.10.11.40.16
        for <linux-mm@kvack.org>;
        Fri, 10 Jan 2014 11:40:17 -0800 (PST)
Message-ID: <52D04367.1070107@redhat.com>
Date: Fri, 10 Jan 2014 14:00:55 -0500
From: Prarit Bhargava <prarit@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] x86, e820 disable ACPI Memory Hotplug if memory mapping
 is specified by user
References: <1389379579-18614-1-git-send-email-prarit@redhat.com> <1389379579-18614-3-git-send-email-prarit@redhat.com>
In-Reply-To: <1389379579-18614-3-git-send-email-prarit@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prarit Bhargava <prarit@redhat.com>
Cc: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Len Brown <lenb@kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Linn Crosetto <linn@hp.com>, Pekka Enberg <penberg@kernel.org>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Toshi Kani <toshi.kani@hp.com>, Tang Chen <tangchen@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Vivek Goyal <vgoyal@redhat.com>, kosaki.motohiro@gmail.com, dyoung@redhat.com, linux-acpi@vger.kernel.org, linux-mm@kvack.org



On 01/10/2014 01:46 PM, Prarit Bhargava wrote:
> kdump uses memmap=exactmap and mem=X values to configure the memory
> mapping for the kdump kernel.  If memory is hotadded during the boot of
> the kdump kernel it is possible that the page tables for the new memory
> cause the kdump kernel to run out of memory.
> 
> Since the user has specified a specific mapping ACPI Memory Hotplug should be
> disabled in this case.
> 

Noticed a bug in this.  Will repost a new version shortly.

P.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
