Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f46.google.com (mail-vk0-f46.google.com [209.85.213.46])
	by kanga.kvack.org (Postfix) with ESMTP id C9A0C82F64
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 22:15:18 -0400 (EDT)
Received: by vkat63 with SMTP id t63so78562159vka.1
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 19:15:18 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id u184si13404919vke.58.2015.10.16.19.15.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 16 Oct 2015 19:15:17 -0700 (PDT)
Message-ID: <1445048104.24309.49.camel@kernel.crashing.org>
Subject: Re: [PATCH 0/3] mm/powerpc: enabling memory soft dirty tracking
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Sat, 17 Oct 2015 07:45:04 +0530
In-Reply-To: <20151016141129.8b014c6d882c475fafe577a9@linux-foundation.org>
References: <cover.1444995096.git.ldufour@linux.vnet.ibm.com>
	 <20151016141129.8b014c6d882c475fafe577a9@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, xemul@parallels.com, linuxppc-dev@lists.ozlabs.org, mpe@ellerman.id.au, aneesh.kumar@linux.vnet.ibm.com, paulus@samba.org, criu@openvz.org

On Fri, 2015-10-16 at 14:11 -0700, Andrew Morton wrote:
> I grabbed these patches, but they're more a ppc thing than a core
> kernel thing.  I can merge them into 4.3 with suitable acks or drop
> them if they turn up in the powerpc tree.  Or something else?

I'm happy for you to keep the generic ones but the powerpc one at the
end should be reviewed by Aneesh at least.

Cheers,
Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
