Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id DEA4A6B0005
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 16:42:25 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id p65so4244256wmp.1
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 13:42:25 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 202si716102wmy.77.2016.03.09.13.42.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Mar 2016 13:42:24 -0800 (PST)
Date: Wed, 9 Mar 2016 13:42:22 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] powerpc/mm: Enable page parallel initialisation
Message-Id: <20160309134222.9c3c7df3dd16956bf7d0c657@linux-foundation.org>
In-Reply-To: <1457429794.31524.1.camel@ellerman.id.au>
References: <1457409354-10867-1-git-send-email-zhlcindy@gmail.com>
	<1457409354-10867-3-git-send-email-zhlcindy@gmail.com>
	<1457429794.31524.1.camel@ellerman.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Li Zhang <zhlcindy@gmail.com>, vbabka@suse.cz, mgorman@techsingularity.net, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, Li Zhang <zhlcindy@linux.vnet.ibm.com>

On Tue, 08 Mar 2016 20:36:34 +1100 Michael Ellerman <mpe@ellerman.id.au> wrote:

> Given that, I think it would be best if Andrew merged both of these patches.
> Because this patch is pretty trivial, whereas the patch to mm/ is less so.
> 
> Is that OK Andrew?

Yep, no probs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
