Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 59D166B02FA
	for <linux-mm@kvack.org>; Wed, 10 May 2017 13:27:57 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id i63so1691981pgd.15
        for <linux-mm@kvack.org>; Wed, 10 May 2017 10:27:57 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id y21si3624251pff.44.2017.05.10.10.27.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 May 2017 10:27:56 -0700 (PDT)
Date: Wed, 10 May 2017 11:27:55 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 0/4 v4] mm,dax: Fix data corruption due to mmap
 inconsistency
Message-ID: <20170510172755.GA18283@linux.intel.com>
References: <20170510085419.27601-1-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170510085419.27601-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, linux-mm@kvack.org

On Wed, May 10, 2017 at 10:54:15AM +0200, Jan Kara wrote:
> Hello,
> 
> this series fixes data corruption that can happen for DAX mounts when
> page faults race with write(2) and as a result page tables get out of sync
> with block mappings in the filesystem and thus data seen through mmap is
> different from data seen through read(2).
> 
> The series passes testing with t_mmap_stale test program from Ross and also
> other mmap related tests on DAX filesystem.
> 
> Andrew, can you please merge these patches? Thanks!
> 
> Changes since v3:
> * Rebased on top of current Linus' tree due to non-trivial conflicts with
>   added tracepoint

Cool, the merge update looks correct to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
