Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4AE736B0003
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 14:57:01 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id 18-v6so8912213pgn.4
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 11:57:01 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 31-v6si22627124plk.397.2018.11.13.11.56.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Nov 2018 11:56:59 -0800 (PST)
Date: Tue, 13 Nov 2018 20:56:54 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH] l1tf: drop the swap storage limit restriction when
 l1tf=off
In-Reply-To: <20181113184910.26697-1-mhocko@kernel.org>
Message-ID: <nycvar.YFH.7.76.1811132054521.19754@cbobk.fhfr.pm>
References: <20181113184910.26697-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <ak@linux.intel.com>, Borislav Petkov <bp@suse.de>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>

On Tue, 13 Nov 2018, Michal Hocko wrote:

> From: Michal Hocko <mhocko@suse.com>
> 
> Swap storage is restricted to max_swapfile_size (~16TB on x86_64)
> whenever the system is deemed affected by L1TF vulnerability. Even
> though the limit is quite high for most deployments it seems to be
> too restrictive for deployments which are willing to live with the
> mitigation disabled.
> 
> We have a customer to deploy 8x 6,4TB PCIe/NVMe SSD swap devices
> which is clearly out of the limit.
> 
> Drop the swap restriction when l1tf=off is specified. It also doesn't
> make much sense to warn about too much memory for the l1tf mitigation
> when it is forcefully disabled by the administrator.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  Documentation/admin-guide/kernel-parameters.txt | 2 ++
>  Documentation/admin-guide/l1tf.rst              | 5 ++++-
>  arch/x86/kernel/cpu/bugs.c                      | 3 ++-
>  arch/x86/mm/init.c                              | 2 +-
>  4 files changed, 9 insertions(+), 3 deletions(-)
> 
> diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
> index 81d1d5a74728..a54f2bd39e77 100644
> --- a/Documentation/admin-guide/kernel-parameters.txt
> +++ b/Documentation/admin-guide/kernel-parameters.txt
> @@ -2095,6 +2095,8 @@
>  			off
>  				Disables hypervisor mitigations and doesn't
>  				emit any warnings.
> +				It also drops the swap size and available
> +				RAM limit restriction.

Minor nit: I think this should explicitly mention that those two things 
are related to bare metal mitigation, to avoid any confusion (as otherwise 
the l1tf cmdline parameter is purely about hypervisor mitigations).

With that

	Acked-by: Jiri Kosina <jkosina@suse.cz>

Thanks,

-- 
Jiri Kosina
SUSE Labs
