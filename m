Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f172.google.com (mail-ie0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id 66D4F6B0035
	for <linux-mm@kvack.org>; Sun, 28 Sep 2014 12:38:55 -0400 (EDT)
Received: by mail-ie0-f172.google.com with SMTP id rl12so1024330iec.17
        for <linux-mm@kvack.org>; Sun, 28 Sep 2014 09:38:55 -0700 (PDT)
Received: from resqmta-po-10v.sys.comcast.net (resqmta-po-10v.sys.comcast.net. [2001:558:fe16:19:96:114:154:169])
        by mx.google.com with ESMTPS id n2si7926518ige.56.2014.09.28.09.38.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 28 Sep 2014 09:38:54 -0700 (PDT)
Date: Sun, 28 Sep 2014 11:38:51 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [REGRESSION] [PATCH 1/3] mm/slab: use percpu allocator for cpu
 cache
In-Reply-To: <20140928062449.GA1277@hudson.localdomain>
Message-ID: <alpine.DEB.2.11.1409281136390.10322@gentwo.org>
References: <1408608675-20420-1-git-send-email-iamjoonsoo.kim@lge.com> <20140928062449.GA1277@hudson.localdomain>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeremiah Mahler <jmmahler@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 27 Sep 2014, Jeremiah Mahler wrote:

> I just encountered a problem on a Lenovo Carbon X1 where it will
> suspend but won't resume.  A bisect indicated that this patch
> is causing the problem.

Could you please not quote the whole patch. Took me a while to find what
you were saying.

> 997888488ef92da365b870247de773255227ce1f
>
> I imagine the patch author, Joonsoo Kim, might have a better idea
> why this is happening than I do.  But if I can provide any information
> or run any tests that might be of help just let me know.

Could you provide more details? Any messages when the system is trying to
resume?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
