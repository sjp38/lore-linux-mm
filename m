Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id ABDA36B0031
	for <linux-mm@kvack.org>; Sat, 11 Jan 2014 11:35:05 -0500 (EST)
Received: by mail-we0-f170.google.com with SMTP id u57so5018153wes.15
        for <linux-mm@kvack.org>; Sat, 11 Jan 2014 08:35:05 -0800 (PST)
Received: from mail-in-08.arcor-online.net (mail-in-08.arcor-online.net. [151.189.21.48])
        by mx.google.com with ESMTPS id m2si3658950wix.60.2014.01.11.08.35.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 11 Jan 2014 08:35:05 -0800 (PST)
Date: Sat, 11 Jan 2014 16:35:00 +0000 (UTC)
From: 7eggert@gmx.de
Subject: Re: [PATCH 2/2] x86, e820 disable ACPI Memory Hotplug if memory
 mapping is specified by user [v2]
In-Reply-To: <1389380698-19361-4-git-send-email-prarit@redhat.com>
Message-ID: <alpine.DEB.2.02.1401111624170.20677@be1.lrz>
References: <1389380698-19361-1-git-send-email-prarit@redhat.com> <1389380698-19361-4-git-send-email-prarit@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prarit Bhargava <prarit@redhat.com>
Cc: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Len Brown <lenb@kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Linn Crosetto <linn@hp.com>, Pekka Enberg <penberg@kernel.org>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Toshi Kani <toshi.kani@hp.com>, Tang Chen <tangchen@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Vivek Goyal <vgoyal@redhat.com>, kosaki.motohiro@gmail.com, dyoung@redhat.com, linux-acpi@vger.kernel.org, linux-mm@kvack.org



On Fri, 10 Jan 2014, Prarit Bhargava wrote:

> kdump uses memmap=exactmap and mem=X values to configure the memory
> mapping for the kdump kernel.  If memory is hotadded during the boot of
> the kdump kernel it is possible that the page tables for the new memory
> cause the kdump kernel to run out of memory.
> 
> Since the user has specified a specific mapping ACPI Memory Hotplug should be
> disabled in this case.

I'll ask just in case: Is it possible to want memory hotplug in spite of 
using memmap=exactmap or mem=X?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
