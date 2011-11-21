Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 8C9726B0069
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 08:16:33 -0500 (EST)
Received: by iaek3 with SMTP id k3so9679485iae.14
        for <linux-mm@kvack.org>; Mon, 21 Nov 2011 05:16:31 -0800 (PST)
From: Namhyung Kim <namhyung@gmail.com>
Subject: Re: [PATCH 2/8] readahead: make default readahead size a kernel parameter
References: <20111121091819.394895091@intel.com>
	<20111121093846.251104145@intel.com>
Date: Mon, 21 Nov 2011 22:16:21 +0900
In-Reply-To: <20111121093846.251104145@intel.com> (Wu Fengguang's message of
	"Mon, 21 Nov 2011 17:18:21 +0800")
Message-ID: <8762id7h0a.fsf@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, Ankit Jain <radical@gmail.com>, Dave Chinner <david@fromorbit.com>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Nikanth Karthikesan <knikanth@suse.de>

Wu Fengguang <fengguang.wu@intel.com> writes:

> From: Nikanth Karthikesan <knikanth@suse.de>
>
> Add new kernel parameter "readahead=", which allows user to override
> the static VM_MAX_READAHEAD=128kb.
>
> CC: Ankit Jain <radical@gmail.com>
> CC: Dave Chinner <david@fromorbit.com>
> CC: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
> Acked-by: Rik van Riel <riel@redhat.com>
> Signed-off-by: Nikanth Karthikesan <knikanth@suse.de>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  Documentation/kernel-parameters.txt |    6 ++++++
>  block/blk-core.c                    |    3 +--
>  fs/fuse/inode.c                     |    2 +-
>  mm/readahead.c                      |   19 +++++++++++++++++++
>  4 files changed, 27 insertions(+), 3 deletions(-)
>
> --- linux-next.orig/Documentation/kernel-parameters.txt	2011-10-19 11:11:14.000000000 +0800
> +++ linux-next/Documentation/kernel-parameters.txt	2011-11-20 11:09:56.000000000 +0800
> @@ -2245,6 +2245,12 @@ bytes respectively. Such letter suffixes
>  			Run specified binary instead of /init from the ramdisk,
>  			used for early userspace startup. See initrd.
>  
> +	readahead=nn[KM]
> +			Default max readahead size for block devices.
> +
> +			This default max readahead size may be overrode

s/overrode/overridden/ ?

Thanks.


> +			in some cases, notably NFS, btrfs and software RAID.
> +
>  	reboot=		[BUGS=X86-32,BUGS=ARM,BUGS=IA-64] Rebooting mode
>  			Format: <reboot_mode>[,<reboot_mode2>[,...]]
>  			See arch/*/kernel/reboot.c or arch/*/kernel/process.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
