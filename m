Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id 03A736B0031
	for <linux-mm@kvack.org>; Fri,  7 Mar 2014 10:33:14 -0500 (EST)
Received: by mail-we0-f179.google.com with SMTP id x48so5121448wes.38
        for <linux-mm@kvack.org>; Fri, 07 Mar 2014 07:33:14 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id e19si9907399wjz.71.2014.03.07.07.33.12
        for <linux-mm@kvack.org>;
        Fri, 07 Mar 2014 07:33:13 -0800 (PST)
Date: Fri, 7 Mar 2014 10:32:59 -0500
From: Dave Jones <davej@redhat.com>
Subject: Re: slub: fix leak of 'name' in sysfs_slab_add
Message-ID: <20140307153259.GA778@redhat.com>
References: <20140306211141.GA17009@redhat.com>
 <5319649C.3060309@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5319649C.3060309@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, cl@linux-foundation.org, penberg@kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Fri, Mar 07, 2014 at 10:18:04AM +0400, Vladimir Davydov wrote:
 > [adding Andrew to Cc]
 > 
 > On 03/07/2014 01:11 AM, Dave Jones wrote:
 > > The failure paths of sysfs_slab_add don't release the allocation of 'name'
 > > made by create_unique_id() a few lines above the context of the diff below.
 > > Create a common exit path to make it more obvious what needs freeing.
 > > 
 > > Signed-off-by: Dave Jones <davej@fedoraproject.org>
 > > 
 > 
 > Since this function was modified in the mmotm tree, I would propose
 > something like this on top of mmotm to avoid further merge conflicts:
 
Looks good to me.

thanks,

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
