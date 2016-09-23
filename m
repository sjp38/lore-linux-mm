Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 83A666B0286
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 12:06:11 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 21so232484417pfy.3
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 09:06:11 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id o63si8412329pfi.291.2016.09.23.09.06.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Sep 2016 09:06:10 -0700 (PDT)
Subject: Re: [PATCH v3 2/2] Documentation/filesystems/proc.txt: Add more
 description for maps/smaps
References: <1474636354-25573-1-git-send-email-robert.hu@intel.com>
 <1474636354-25573-2-git-send-email-robert.hu@intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <57E552F2.4030302@intel.com>
Date: Fri, 23 Sep 2016 09:06:10 -0700
MIME-Version: 1.0
In-Reply-To: <1474636354-25573-2-git-send-email-robert.hu@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robert Ho <robert.hu@intel.com>, pbonzini@redhat.com, akpm@linux-foundation.org, mhocko@suse.com, oleg@redhat.com, dan.j.williams@intel.com
Cc: guangrong.xiao@linux.intel.com, gleb@kernel.org, mtosatti@redhat.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, stefanha@redhat.com, yuhuang@redhat.com, linux-mm@kvack.org, ross.zwisler@linux.intel.com

On 09/23/2016 06:12 AM, Robert Ho wrote:
> +Note: for both /proc/PID/maps and /proc/PID/smaps readings, it's
> +possible in race conditions, that the mappings printed may not be that
> +up-to-date, because during each read walking, the task's mappings may have
> +changed, this typically happens in multithread cases. But anyway in each single
> +read these can be guarunteed: 1) the mapped addresses doesn't go backward; 2) no
> +overlaps 3) if there is something at a given vaddr during the entirety of the
> +life of the smaps/maps walk, there will be some output for it.

Could we spuce this description up a bit?  Perhaps:

Note: reading /proc/PID/maps or /proc/PID/smaps is inherently racy.
This typically manifests when doing partial reads of these files while
the memory map is being modified.  Despite the races, we do provide the
following guarantees:
1) The mapped addresses never go backwards, which implies no two
   regions will ever overlap.
2) If there is something at a given vaddr during the entirety of the
   life of the smaps/maps walk, there will be some output for it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
