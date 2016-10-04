Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6AAC06B0038
	for <linux-mm@kvack.org>; Tue,  4 Oct 2016 04:39:26 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id 2so92982866vkb.2
        for <linux-mm@kvack.org>; Tue, 04 Oct 2016 01:39:26 -0700 (PDT)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id e70si1097118vkf.89.2016.10.04.01.39.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Oct 2016 01:39:25 -0700 (PDT)
Date: Tue, 4 Oct 2016 03:36:53 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/1] man/set_mempolicy.2,mbind.2: add MPOL_LOCAL NUMA
 memory policy documentation
In-Reply-To: <20160927131948.11974-1-kwapulinski.piotr@gmail.com>
Message-ID: <alpine.DEB.2.20.1610040333050.10814@east.gentwo.org>
References: <alpine.DEB.2.10.1609201304450.134671@chino.kir.corp.google.com> <20160927131948.11974-1-kwapulinski.piotr@gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Cc: mtk.manpages@gmail.com, kirill.shutemov@linux.intel.com, vbabka@suse.cz, rientjes@google.com, mhocko@kernel.org, mgorman@techsingularity.net, liangchen.linux@gmail.com, nzimmer@sgi.com, a.p.zijlstra@chello.nl, riel@redhat.com, lee.schermerhorn@hp.com, jmarchan@redhat.com, joe@perches.com, corbet@lwn.net, iamyooon@gmail.com, n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-man@vger.kernel.org, akpm@linux-foundation.org, linux-doc@vger.kernel.org, linux-api@vger.kernel.org

Well the difference between MPOL_DEFAULT and MPOL_LOCAL may be confusing.
Mention somewhere in the MPOL_LOCAL description that the policy with
MPOL_DEFAULT reverts to the policy of the process and MPOL_LOCAL to try to
allocate local? Note that MPOL_LOCAL also will not be local if it just
happens that the local node is overallocated. This is usually confusing
for newcomers. The node/zone reclaim must be activated in order to allow
node local reclaim that results in a node local allocation.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
