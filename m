Date: Tue, 20 May 2003 12:52:31 -0700
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: 2.5.69-mm7
Message-ID: <535806509.1053435150@IBM-O1F8DZ9MWMH>
In-Reply-To: <20030519012336.44d0083a.akpm@digeo.com>
References: <20030519012336.44d0083a.akpm@digeo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Seems that -mm7, has broken compilation of subarch visws:

arch/i386/kernel/built-in.o: In function `cpu_stop_apics':
arch/i386/kernel/built-in.o(.text+0xe511): undefined reference to 
`stop_this_cpu'
arch/i386/kernel/built-in.o: In function `stop_apics':
arch/i386/kernel/built-in.o(.text+0xe552): undefined reference to 
`reboot_cpu'
arch/i386/mach-visws/built-in.o: In function `machine_restart':
arch/i386/mach-visws/built-in.o(.text+0x1): undefined reference to 
`smp_send_stop'

Seems that the culprit is the reboot on boot processor changes, reverting 
the following patches fixes the compilation:

	patch -R -p1 <kexec-revert-NORET_TYPE.patch
	patch -R -p1 <reboot_on_bsp.patch

Cheers.

-apw
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
