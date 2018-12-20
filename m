Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3EA028E0003
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 02:59:25 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id t10so749141plo.13
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 23:59:25 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id o6si17976689plh.23.2018.12.19.23.59.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 23:59:24 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wBK7sE14141066
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 02:59:23 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2pg6p0sadj-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 02:59:23 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 20 Dec 2018 07:59:21 -0000
Date: Thu, 20 Dec 2018 09:59:13 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH 0/2] docs/mm-api: link kernel-doc comments from
 slab_common.c
References: <1544130781-13443-1-git-send-email-rppt@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1544130781-13443-1-git-send-email-rppt@linux.ibm.com>
Message-Id: <20181220075912.GA12338@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

ping?

On Thu, Dec 06, 2018 at 11:12:59PM +0200, Mike Rapoport wrote:
> Hi,
> 
> These patches update formatting of function descriptions in
> mm/slab_common.c and link the comments from this file to "The Slab Cache"
> section of the MM API reference.
> 
> As the changes to mm/slab_common.c only touch the comments, I think these
> patches can go via the docs tree.
> 
> Mike Rapoport (2):
>   slab: make kmem_cache_create{_usercopy} description proper kernel-doc
>   docs/mm-api: link slab_common.c to "The Slab Cache" section
> 
>  Documentation/core-api/mm-api.rst |  3 +++
>  mm/slab_common.c                  | 35 +++++++++++++++++++++++++++++++----
>  2 files changed, 34 insertions(+), 4 deletions(-)
> 
> -- 
> 2.7.4
> 

-- 
Sincerely yours,
Mike.
