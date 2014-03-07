Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 253226B0036
	for <linux-mm@kvack.org>; Fri,  7 Mar 2014 12:14:18 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id lj1so4383258pab.8
        for <linux-mm@kvack.org>; Fri, 07 Mar 2014 09:14:17 -0800 (PST)
Received: from qmta01.emeryville.ca.mail.comcast.net (qmta01.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:16])
        by mx.google.com with ESMTP id bo2si8930574pbc.81.2014.03.07.09.14.16
        for <linux-mm@kvack.org>;
        Fri, 07 Mar 2014 09:14:17 -0800 (PST)
Date: Fri, 7 Mar 2014 11:14:14 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: slub: fix leak of 'name' in sysfs_slab_add
In-Reply-To: <20140307153259.GA778@redhat.com>
Message-ID: <alpine.DEB.2.10.1403071113590.21846@nuc>
References: <20140306211141.GA17009@redhat.com> <5319649C.3060309@parallels.com> <20140307153259.GA778@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, penberg@kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Fri, 7 Mar 2014, Dave Jones wrote:

>  > Since this function was modified in the mmotm tree, I would propose
>  > something like this on top of mmotm to avoid further merge conflicts:
>
> Looks good to me.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
