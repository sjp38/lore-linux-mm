Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 5D3876B0038
	for <linux-mm@kvack.org>; Fri, 26 Sep 2014 11:44:50 -0400 (EDT)
Received: by mail-ie0-f170.google.com with SMTP id x19so13114420ier.29
        for <linux-mm@kvack.org>; Fri, 26 Sep 2014 08:44:50 -0700 (PDT)
Received: from qmta05.westchester.pa.mail.comcast.net (qmta05.westchester.pa.mail.comcast.net. [2001:558:fe14:43:76:96:62:48])
        by mx.google.com with ESMTP id ox6si7238482icb.56.2014.09.26.08.44.48
        for <linux-mm@kvack.org>;
        Fri, 26 Sep 2014 08:44:49 -0700 (PDT)
Date: Fri, 26 Sep 2014 10:44:47 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/4] cpuset: convert callback_mutex to a spinlock
In-Reply-To: <778e648ce62511c7aff225ca067e0abedb247f25.1411741632.git.vdavydov@parallels.com>
Message-ID: <alpine.DEB.2.11.1409261039410.3870@gentwo.org>
References: <cover.1411741632.git.vdavydov@parallels.com> <778e648ce62511c7aff225ca067e0abedb247f25.1411741632.git.vdavydov@parallels.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: linux-kernel@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Fri, 26 Sep 2014, Vladimir Davydov wrote:

> The callback_mutex is only used to synchronize reads/updates of cpusets'
> flags and cpu/node masks. These operations should always proceed fast so
> there's no reason why we can't use a spinlock instead of the mutex.

Checked that and given the other restrictions already on the use of
callback_mutex this is to be expected.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
