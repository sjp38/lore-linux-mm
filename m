Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 747C76B038D
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 06:01:47 -0500 (EST)
Received: by mail-ua0-f199.google.com with SMTP id d38so90167919uad.4
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 03:01:47 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id n64si193085pgn.27.2017.02.14.03.01.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 14 Feb 2017 03:01:46 -0800 (PST)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH 2/2] powerpc/mm/autonuma: Switch ppc64 to its own implementeation of saved write
In-Reply-To: <1487044759.21048.24.camel@neuling.org>
References: <1486609259-6796-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1486609259-6796-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1487044759.21048.24.camel@neuling.org>
Date: Tue, 14 Feb 2017 22:01:43 +1100
Message-ID: <871sv1m3xk.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Neuling <mikey@neuling.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, akpm@linux-foundation.org, Rik van Riel <riel@surriel.com>, Mel Gorman <mgorman@techsingularity.net>, paulus@ozlabs.org, benh@kernel.crashing.org
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

Michael Neuling <mikey@neuling.org> writes:

> On Thu, 2017-02-09 at 08:30 +0530, Aneesh Kumar K.V wrote:
>> With this our protnone becomes a present pte with READ/WRITE/EXEC bit cleared.
>> By default we also set _PAGE_PRIVILEGED on such pte. This is now used to help
>> us identify a protnone pte that as saved write bit. For such pte, we will
>> clear
>> the _PAGE_PRIVILEGED bit. The pte still remain non-accessible from both user
>> and kernel.
>> 
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>
>
> FWIW I've tested this, so:
>
> Acked-By: Michael Neuling <mikey@neuling.org>

In future if you've tested something then "Tested-by:" is the right tag
to use.

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
