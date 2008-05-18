Received: by rv-out-0708.google.com with SMTP id f25so1218863rvb.26
        for <linux-mm@kvack.org>; Sun, 18 May 2008 10:07:11 -0700 (PDT)
Message-ID: <2f11576a0805181007n14592bd0r1cf8aec915894ed5@mail.gmail.com>
Date: Mon, 19 May 2008 02:07:11 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [BUG] 2.6.26-rc2-mm1 - kernel bug while bootup at __alloc_pages_internal () on x86_64
In-Reply-To: <20080518080013.GA17458@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080514010129.4f672378.akpm@linux-foundation.org>
	 <482ACBFE.9010606@linux.vnet.ibm.com>
	 <20080514103601.32d20889.akpm@linux-foundation.org>
	 <482B2DB0.9030102@linux.vnet.ibm.com>
	 <20080514124455.cf7c3097.akpm@linux-foundation.org>
	 <20080518080013.GA17458@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, apw@shadowen.org, balbir@linux.vnet.ibm.com, linux-mm@kvack.org, mingo@elte.hu, kosaki.motohiro@jp.fujitsu.com, kosaki.motohiro@gmail.com
List-ID: <linux-mm.kvack.org>

> After bisecting, the acpi-acpi_numa_init-build-fix.patch patch seems
> to be causing the kernel panic during the bootup. Reverting the patch helps
> in booting up the machine without the panic.
>
> commit 5dc90c0b2d4bd0127624bab67cec159b2c6c4daf
> Author: Ingo Molnar <mingo@elte.hu>
> Date:   Thu May 1 09:51:47 2008 +0000
>
>    acpi-acpi_numa_init-build-fix

this patch break Fujitsu ia64 numa box too.
after revert, my test environment works well.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
