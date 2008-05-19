Subject: Re: [BUG] 2.6.26-rc2-mm1 - kernel bug while bootup at
	__alloc_pages_internal () on x86_64
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <2f11576a0805181007n14592bd0r1cf8aec915894ed5@mail.gmail.com>
References: <20080514010129.4f672378.akpm@linux-foundation.org>
	 <482ACBFE.9010606@linux.vnet.ibm.com>
	 <20080514103601.32d20889.akpm@linux-foundation.org>
	 <482B2DB0.9030102@linux.vnet.ibm.com>
	 <20080514124455.cf7c3097.akpm@linux-foundation.org>
	 <20080518080013.GA17458@linux.vnet.ibm.com>
	 <2f11576a0805181007n14592bd0r1cf8aec915894ed5@mail.gmail.com>
Content-Type: text/plain
Date: Mon, 19 May 2008 10:49:12 -0400
Message-Id: <1211208552.6322.5.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, apw@shadowen.org, balbir@linux.vnet.ibm.com, linux-mm@kvack.org, mingo@elte.hu, kosaki.motohiro@gmail.com
List-ID: <linux-mm.kvack.org>

On Mon, 2008-05-19 at 02:07 +0900, KOSAKI Motohiro wrote:
> > After bisecting, the acpi-acpi_numa_init-build-fix.patch patch seems
> > to be causing the kernel panic during the bootup. Reverting the patch helps
> > in booting up the machine without the panic.
> >
> > commit 5dc90c0b2d4bd0127624bab67cec159b2c6c4daf
> > Author: Ingo Molnar <mingo@elte.hu>
> > Date:   Thu May 1 09:51:47 2008 +0000
> >
> >    acpi-acpi_numa_init-build-fix
> 
> this patch break Fujitsu ia64 numa box too.
> after revert, my test environment works well.

On HP ia64 numa, that patch causes all memory to show up on node 0, but
otherwise the platform boots and runs.  Didn't notice it until I tried
to run some numa tests.

Reverting the patch restores numaness.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
