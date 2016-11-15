Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 099AE6B0267
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 02:01:00 -0500 (EST)
Received: by mail-pa0-f70.google.com with SMTP id bi5so109466198pad.0
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 23:01:00 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id s5si25257184pfj.271.2016.11.14.23.00.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Nov 2016 23:00:58 -0800 (PST)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH v1 3/3] powerpc: fix node_possible_map limitations
In-Reply-To: <1479167045-28136-4-git-send-email-bsingharora@gmail.com>
References: <1479167045-28136-1-git-send-email-bsingharora@gmail.com> <1479167045-28136-4-git-send-email-bsingharora@gmail.com>
Date: Tue, 15 Nov 2016 18:00:52 +1100
Message-ID: <8760npz0pn.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org
Cc: linuxppc-dev@lists.ozlabs.org, akpm@linux-foundation.org, tj@kernel.org

Can you make the subject a bit more descriptive?

Currently this prevents node hotplug, so it's required that we remove it
to support that IIUIC.

Balbir Singh <bsingharora@gmail.com> writes:
> We've fixed the memory hotplug issue with memcg, hence
> this work around should not be required.
>
> Fixes: commit 3af229f2071f
> ("powerpc/numa: Reset node_possible_map to only node_online_map")

I don't think Fixes is right here, that commit wasn't buggy, it was just
a workaround for the code at that time.

Just say "This is a revert of commit 3af229f2071f ("powerpc/numa: Reset
node_possible_map to only node_online_map")".

Otherwise LGTM to go via mm.

Acked-by: Michael Ellerman <mpe@ellerman.id.au>

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
