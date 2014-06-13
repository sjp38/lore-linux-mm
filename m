Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f41.google.com (mail-qa0-f41.google.com [209.85.216.41])
	by kanga.kvack.org (Postfix) with ESMTP id 205646B0031
	for <linux-mm@kvack.org>; Fri, 13 Jun 2014 11:53:56 -0400 (EDT)
Received: by mail-qa0-f41.google.com with SMTP id cm18so3967089qab.14
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 08:53:55 -0700 (PDT)
Received: from qmta06.emeryville.ca.mail.comcast.net (qmta06.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:56])
        by mx.google.com with ESMTP id i10si2170894qgd.66.2014.06.13.08.53.55
        for <linux-mm@kvack.org>;
        Fri, 13 Jun 2014 08:53:55 -0700 (PDT)
Date: Fri, 13 Jun 2014 10:53:50 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH] slub: correct return errno on slab_sysfs_init failure
In-Reply-To: <5399A360.3060309@oracle.com>
Message-ID: <alpine.DEB.2.10.1406131050430.913@gentwo.org>
References: <5399A360.3060309@oracle.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Liu <jeff.liu@oracle.com>
Cc: linux-mm@kvack.org, penberg@kernel.org, mpm@selenic.com


On Thu, 12 Jun 2014, Jeff Liu wrote:

> From: Jie Liu <jeff.liu@oracle.com>
>
> Return ENOMEM instead of ENOSYS if slab_sysfs_init() failed

The reason that I used ENOSYS there is that the whole sysfs portion of the
slab allocator will be disabled. Could be due to a number of issues since
kset_create_and_add() returns NULL for any error.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
