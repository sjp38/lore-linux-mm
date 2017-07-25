Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8B66C6B02B4
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 05:09:34 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 72so74163937pfl.12
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 02:09:34 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id q123si7799821pfb.349.2017.07.25.02.09.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 25 Jul 2017 02:09:33 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH v2] mm: Drop useless local parameters of __register_one_node()
In-Reply-To: <1498013846-20149-1-git-send-email-douly.fnst@cn.fujitsu.com>
References: <1498013846-20149-1-git-send-email-douly.fnst@cn.fujitsu.com>
Date: Tue, 25 Jul 2017 19:09:29 +1000
Message-ID: <87d18o7uie.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dou Liyang <douly.fnst@cn.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@kernel.org>, isimatu.yasuaki@jp.fujitsu.com

Dou Liyang <douly.fnst@cn.fujitsu.com> writes:

> ... initializes local parameters "p_node" & "parent" for
> register_node().
>
> But, register_node() does not use them.
>
> Remove the related code of "parent" node, cleanup __register_one_node()
> and register_node().
>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: isimatu.yasuaki@jp.fujitsu.com
> Signed-off-by: Dou Liyang <douly.fnst@cn.fujitsu.com>
> Acked-by: David Rientjes <rientjes@google.com>
> ---
> V1 --> V2:
> Rebase it on 
> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git akpm
>
>  drivers/base/node.c | 9 ++-------
>  1 file changed, 2 insertions(+), 7 deletions(-)

That appears to be the last user of parent_node().

Can we start removing it from the topology.h headers for each arch?

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
