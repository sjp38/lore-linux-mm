Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 6B3736B0038
	for <linux-mm@kvack.org>; Fri, 26 Sep 2014 11:53:17 -0400 (EDT)
Received: by mail-ie0-f173.google.com with SMTP id lx4so246514iec.32
        for <linux-mm@kvack.org>; Fri, 26 Sep 2014 08:53:17 -0700 (PDT)
Received: from resqmta-po-09v.sys.comcast.net (resqmta-po-09v.sys.comcast.net. [2001:558:fe16:19:96:114:154:168])
        by mx.google.com with ESMTPS id mx1si2661566igb.51.2014.09.26.08.53.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 26 Sep 2014 08:53:16 -0700 (PDT)
Date: Fri, 26 Sep 2014 10:53:14 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/4] cpuset: simplify cpuset_node_allowed API
In-Reply-To: <ad9b25d464c2050aa2b5016db8eadcc7a6859967.1411741632.git.vdavydov@parallels.com>
Message-ID: <alpine.DEB.2.11.1409261052490.3870@gentwo.org>
References: <cover.1411741632.git.vdavydov@parallels.com> <ad9b25d464c2050aa2b5016db8eadcc7a6859967.1411741632.git.vdavydov@parallels.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Li Zefan <lizefan@huawei.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Fri, 26 Sep 2014, Vladimir Davydov wrote:

> So let's simplify the API back to the single check.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
