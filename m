Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f175.google.com (mail-qc0-f175.google.com [209.85.216.175])
	by kanga.kvack.org (Postfix) with ESMTP id 7ED9B900015
	for <linux-mm@kvack.org>; Tue, 21 Apr 2015 10:06:12 -0400 (EDT)
Received: by qcrf4 with SMTP id f4so76230297qcr.0
        for <linux-mm@kvack.org>; Tue, 21 Apr 2015 07:06:12 -0700 (PDT)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id j88si1863261qgf.96.2015.04.21.07.06.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 21 Apr 2015 07:06:10 -0700 (PDT)
Date: Tue, 21 Apr 2015 09:06:07 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/slab_common: Support the slub_debug boot option on
 specific object size
In-Reply-To: <CA+eFSM3yfHQ58ruSP3sFq8EyJQsxdSoX3gB9CU38SAkh2+t19w@mail.gmail.com>
Message-ID: <alpine.DEB.2.11.1504210905540.20333@gentwo.org>
References: <1429349091-11785-1-git-send-email-gavin.guo@canonical.com> <alpine.DEB.2.11.1504201040010.2264@gentwo.org> <CA+eFSM3yfHQ58ruSP3sFq8EyJQsxdSoX3gB9CU38SAkh2+t19w@mail.gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Guo <gavin.guo@canonical.com>
Cc: penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>

On Tue, 21 Apr 2015, Gavin Guo wrote:

> Thanks for your reply. I put the kmalloc_names in the __initdata
> section. And it will be cleaned. Do you think the kmalloc_names should
> be put in the global data section to avoid the dynamic creation of the
> kmalloc hostname again?

Yes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
