Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 444E76B0033
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 16:40:00 -0400 (EDT)
Message-ID: <52210314.4080408@zytor.com>
Date: Fri, 30 Aug 2013 13:39:48 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH] x86: e820: fix memmap kernel boot parameter
References: <1377841673-17361-1-git-send-email-bob.liu@oracle.com>
In-Reply-To: <1377841673-17361-1-git-send-email-bob.liu@oracle.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, hpa@linux.intel.com, yinghai@kernel.org, jacob.shin@amd.com, konrad.wilk@oracle.com, linux-mm@kvack.org, Bob Liu <bob.liu@oracle.com>

On 08/29/2013 10:47 PM, Bob Liu wrote:
> Kernel boot parameter memmap=nn[KMG]$ss[KMG] is used to mark specific memory as
> reserved. Region of memory to be used is from ss to ss+nn.
> 
> But I found the action of this parameter is not as expected.
> I tried on two machines.
> Machine1: bootcmdline in grub.cfg "memmap=800M$0x60bfdfff", but the result of
> "cat /proc/cmdline" changed to "memmap=800M/bin/bashx60bfdfff" after system
> booted.
> 
> Machine2: bootcmdline in grub.cfg "memmap=0x77ffffff$0x880000000", the result of
> "cat /proc/cmdline" changed to "memmap=0x77ffffffx880000000".
> 
> I didn't find the root cause, I think maybe grub reserved "$0" as something
> special.
> Replace '$' with '%' in kernel boot parameter can fix this issue.

NAK for the reasons already discussed.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
