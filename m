Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1AE9028024E
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 22:28:01 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id bv10so57694485pad.2
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 19:28:01 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id he1si3038587pac.124.2016.09.27.19.28.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Sep 2016 19:28:00 -0700 (PDT)
Message-ID: <1475029652.1037.2.camel@vmm.sh.intel.com>
Subject: Re: [PATCH v3 2/2] Documentation/filesystems/proc.txt: Add more
 description for maps/smaps
From: Robert Hu <robert.hu@vmm.sh.intel.com>
Reply-To: robert.hu@intel.com
Date: Wed, 28 Sep 2016 10:27:32 +0800
In-Reply-To: <57E552F2.4030302@intel.com>
References: <1474636354-25573-1-git-send-email-robert.hu@intel.com>
	 <1474636354-25573-2-git-send-email-robert.hu@intel.com>
	 <57E552F2.4030302@intel.com>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Robert Ho <robert.hu@intel.com>, pbonzini@redhat.com, akpm@linux-foundation.org, mhocko@suse.com, oleg@redhat.com, dan.j.williams@intel.com, guangrong.xiao@linux.intel.com, gleb@kernel.org, mtosatti@redhat.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, stefanha@redhat.com, yuhuang@redhat.com, linux-mm@kvack.org, ross.zwisler@linux.intel.com

On Fri, 2016-09-23 at 09:06 -0700, Dave Hansen wrote:
> On 09/23/2016 06:12 AM, Robert Ho wrote:
> > +Note: for both /proc/PID/maps and /proc/PID/smaps readings, it's
> > +possible in race conditions, that the mappings printed may not be that
> > +up-to-date, because during each read walking, the task's mappings may have
> > +changed, this typically happens in multithread cases. But anyway in each single
> > +read these can be guarunteed: 1) the mapped addresses doesn't go backward; 2) no
> > +overlaps 3) if there is something at a given vaddr during the entirety of the
> > +life of the smaps/maps walk, there will be some output for it.
> 
> Could we spuce this description up a bit?  Perhaps:
> 
> Note: reading /proc/PID/maps or /proc/PID/smaps is inherently racy.
> This typically manifests when doing partial reads of these files while
> the memory map is being modified.  Despite the races, we do provide the
> following guarantees:
> 1) The mapped addresses never go backwards, which implies no two
>    regions will ever overlap.
> 2) If there is something at a given vaddr during the entirety of the
>    life of the smaps/maps walk, there will be some output for it.
Sure. Thanks Dave for helping make it more concise and correct.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
