Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id C52636B0005
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 00:25:36 -0500 (EST)
Received: by mail-qg0-f51.google.com with SMTP id b67so103793088qgb.1
        for <linux-mm@kvack.org>; Sun, 14 Feb 2016 21:25:36 -0800 (PST)
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com. [129.33.205.209])
        by mx.google.com with ESMTPS id e5si32493741qkb.92.2016.02.14.21.25.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sun, 14 Feb 2016 21:25:36 -0800 (PST)
Received: from localhost
	by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 15 Feb 2016 00:25:35 -0500
Received: from b01cxnp23034.gho.pok.ibm.com (b01cxnp23034.gho.pok.ibm.com [9.57.198.29])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 2C64DC9003E
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 00:25:31 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by b01cxnp23034.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1F5PXj130867668
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 05:25:33 GMT
Received: from d01av04.pok.ibm.com (localhost [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1F5PWhe012440
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 00:25:32 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH V2 05/29] powerpc/mm: Copy pgalloc (part 2)
In-Reply-To: <20160212035334.GD13831@oak.ozlabs.ibm.com>
References: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1454923241-6681-6-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20160212035334.GD13831@oak.ozlabs.ibm.com>
Date: Mon, 15 Feb 2016 10:55:27 +0530
Message-ID: <87fuwufsu0.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Mackerras <paulus@ozlabs.org>
Cc: benh@kernel.crashing.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Paul Mackerras <paulus@ozlabs.org> writes:

> On Mon, Feb 08, 2016 at 02:50:17PM +0530, Aneesh Kumar K.V wrote:
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>
> This needs a proper patch description.
>
> Paul.

I am expecting part1, 2 and 3 will be folded into one patch before
merge. I updated part1 with

powerpc/mm: Copy pgalloc (part 1)

This patch make a copy of pgalloc routines for book3s. The idea is to
enable a hash64 copy of these pgalloc routines which can be later
updated to have a radix conditional. Radix introduce a new page table
format with different page table size.

This mostly does:

cp pgalloc-32.h book3s/32/pgalloc.h
cp pgalloc-64.h book3s/64/pgalloc.h

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
