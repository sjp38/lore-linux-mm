Subject: Re: 2.5.69-mm7
References: <20030519012336.44d0083a.akpm@digeo.com>
	<535806509.1053435150@IBM-O1F8DZ9MWMH>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 20 May 2003 14:01:56 -0600
In-Reply-To: <535806509.1053435150@IBM-O1F8DZ9MWMH>
Message-ID: <m1fzn91j63.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andy Whitcroft <apw@shadowen.org> writes:

> Seems that -mm7, has broken compilation of subarch visws:
> 
> arch/i386/kernel/built-in.o: In function `cpu_stop_apics':
> arch/i386/kernel/built-in.o(.text+0xe511): undefined reference to
> `stop_this_cpu'
> 
> arch/i386/kernel/built-in.o: In function `stop_apics':
> arch/i386/kernel/built-in.o(.text+0xe552): undefined reference to `reboot_cpu'
> arch/i386/mach-visws/built-in.o: In function `machine_restart':
> arch/i386/mach-visws/built-in.o(.text+0x1): undefined reference to
> `smp_send_stop'
> 
> Seems that the culprit is the reboot on boot processor changes, reverting the
> following patches fixes the compilation:
> 
> 	patch -R -p1 <kexec-revert-NORET_TYPE.patch
> 	patch -R -p1 <reboot_on_bsp.patch
> 
> Cheers.

Do you have a machine to test against.  Or is this a test for completeness?

I don't get the subarch factoring.  And as such I cannot see how to
properly fixup the subarch code.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
