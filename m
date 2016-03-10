Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 22EED6B0005
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 19:28:41 -0500 (EST)
Received: by mail-pf0-f178.google.com with SMTP id 129so54029732pfw.1
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 16:28:41 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id ko9si1641302pab.187.2016.03.09.16.28.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Mar 2016 16:28:40 -0800 (PST)
Message-ID: <1457569716.28944.0.camel@ellerman.id.au>
Subject: Re: [PATCH 2/2] powerpc/mm: Enable page parallel initialisation
From: Michael Ellerman <mpe@ellerman.id.au>
Date: Thu, 10 Mar 2016 11:28:36 +1100
In-Reply-To: <20160309134222.9c3c7df3dd16956bf7d0c657@linux-foundation.org>
References: <1457409354-10867-1-git-send-email-zhlcindy@gmail.com>
	 <1457409354-10867-3-git-send-email-zhlcindy@gmail.com>
	 <1457429794.31524.1.camel@ellerman.id.au>
	 <20160309134222.9c3c7df3dd16956bf7d0c657@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Li Zhang <zhlcindy@gmail.com>, vbabka@suse.cz, mgorman@techsingularity.net, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, Li Zhang <zhlcindy@linux.vnet.ibm.com>

On Wed, 2016-03-09 at 13:42 -0800, Andrew Morton wrote:
> On Tue, 08 Mar 2016 20:36:34 +1100 Michael Ellerman <mpe@ellerman.id.au> wrote:
>
> > Given that, I think it would be best if Andrew merged both of these patches.
> > Because this patch is pretty trivial, whereas the patch to mm/ is less so.
> >
> > Is that OK Andrew?
>
> Yep, no probs.

Thanks.

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
