Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 6B6289003C8
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 05:34:55 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so39922952pdr.2
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 02:34:55 -0700 (PDT)
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com. [209.85.192.179])
        by mx.google.com with ESMTPS id bp9si9165914pdb.52.2015.07.31.02.34.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Jul 2015 02:34:54 -0700 (PDT)
Received: by pdbnt7 with SMTP id nt7so39891511pdb.0
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 02:34:54 -0700 (PDT)
Date: Fri, 31 Jul 2015 15:04:50 +0530
From: Viresh Kumar <viresh.kumar@linaro.org>
Subject: Re: [PATCH 14/15] mm: Drop unlikely before IS_ERR(_OR_NULL)
Message-ID: <20150731093450.GA7505@linux>
References: <cover.1438331416.git.viresh.kumar@linaro.org>
 <91586af267deb26b905fba61a9f1f665a204a4e3.1438331416.git.viresh.kumar@linaro.org>
 <20150731085646.GA31544@node.dhcp.inet.fi>
 <FA3D9AE9-9D1E-4232-87DE-42F21B408B24@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <FA3D9AE9-9D1E-4232-87DE-42F21B408B24@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yalin wang <yalin.wang2010@gmail.com>, Joe Perches <joe@perches.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, linaro-kernel@lists.linaro.org, open list <linux-kernel@vger.kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>

On 31-07-15, 17:32, yalin wang wrote:
> 
> > On Jul 31, 2015, at 16:56, Kirill A. Shutemov <kirill@shutemov.name> wrote:
> > 
> > On Fri, Jul 31, 2015 at 02:08:34PM +0530, Viresh Kumar wrote:
> >> IS_ERR(_OR_NULL) already contain an 'unlikely' compiler flag and there
> >> is no need to do that again from its callers. Drop it.
> >> 
> >> Signed-off-by: Viresh Kumar <viresh.kumar@linaro.org>
> > 
> > Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

> search in code, there are lots of using like this , does need add this check into checkpatch ?

cc'd Joe for that. :)

> # grep -r 'likely.*IS_ERR'  .
> ./include/linux/blk-cgroup.h:	if (unlikely(IS_ERR(blkg)))
> ./fs/nfs/objlayout/objio_osd.c:	if (unlikely(IS_ERR(od))) {
> ./fs/cifs/readdir.c:	if (unlikely(IS_ERR(dentry)))
> ./fs/ext4/extents.c:		if (unlikely(IS_ERR(bh))) {
> ./fs/ext4/extents.c:		if (unlikely(IS_ERR(path1))) {
> ./fs/ext4/extents.c:		if (unlikely(IS_ERR(path2))) {

Btw, my series has fixed all of them :)

-- 
viresh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
