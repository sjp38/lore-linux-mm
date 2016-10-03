Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id CFCB76B0069
	for <linux-mm@kvack.org>; Mon,  3 Oct 2016 07:53:57 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id d64so78962261wmh.1
        for <linux-mm@kvack.org>; Mon, 03 Oct 2016 04:53:57 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id q4si6392093wjz.292.2016.10.03.04.53.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Oct 2016 04:53:56 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id b184so14314128wma.3
        for <linux-mm@kvack.org>; Mon, 03 Oct 2016 04:53:56 -0700 (PDT)
Date: Mon, 3 Oct 2016 13:53:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v4 2/2] Dcumentation/filesystems/proc.txt: Add more
 description for maps/smaps
Message-ID: <20161003115355.GB26768@dhcp22.suse.cz>
References: <1475296958-27652-1-git-send-email-robert.hu@intel.com>
 <1475296958-27652-2-git-send-email-robert.hu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1475296958-27652-2-git-send-email-robert.hu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robert Ho <robert.hu@intel.com>
Cc: pbonzini@redhat.com, akpm@linux-foundation.org, oleg@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com, guangrong.xiao@linux.intel.com, gleb@kernel.org, mtosatti@redhat.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, stefanha@redhat.com, yuhuang@redhat.com, linux-mm@kvack.org, ross.zwisler@linux.intel.com

On Sat 01-10-16 12:42:38, Robert Ho wrote:
> Add some more description on the limitations for smaps/maps readings, as well
> as some guaruntees we can make.
> 
> Changelog:
> v2:
> 	Adopt Dave Hansen's revision from v1 as the description.
> 
> Signed-off-by: Robert Ho <robert.hu@intel.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  Documentation/filesystems/proc.txt | 12 ++++++++++++
>  1 file changed, 12 insertions(+)
> 
> diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
> index 68080ad..daa096f 100644
> --- a/Documentation/filesystems/proc.txt
> +++ b/Documentation/filesystems/proc.txt
> @@ -515,6 +515,18 @@ be vanished or the reverse -- new added.
>  This file is only present if the CONFIG_MMU kernel configuration option is
>  enabled.
>  
> +Note: reading /proc/PID/maps or /proc/PID/smaps is inherently racy (consistent
> +output can be achieved only in the single read call).
> +This typically manifests when doing partial reads of these files while the
> +memory map is being modified.  Despite the races, we do provide the following
> +guarantees:
> +
> +1) The mapped addresses never go backwards, which implies no two
> +   regions will ever overlap.
> +2) If there is something at a given vaddr during the entirety of the
> +   life of the smaps/maps walk, there will be some output for it.
> +
> +
>  The /proc/PID/clear_refs is used to reset the PG_Referenced and ACCESSED/YOUNG
>  bits on both physical and virtual pages associated with a process, and the
>  soft-dirty bit on pte (see Documentation/vm/soft-dirty.txt for details).
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
