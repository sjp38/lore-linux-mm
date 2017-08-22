Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4C2FA6B04C5
	for <linux-mm@kvack.org>; Mon, 21 Aug 2017 21:46:11 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c67so37253722pfj.7
        for <linux-mm@kvack.org>; Mon, 21 Aug 2017 18:46:11 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id q6si7920433pgn.509.2017.08.21.18.46.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 21 Aug 2017 18:46:10 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH v2 17/20] perf: Add a speculative page fault sw event
In-Reply-To: <cd2f451d-c6d6-1ff5-b7d9-d3d0937ae056@linux.vnet.ibm.com>
References: <1503007519-26777-1-git-send-email-ldufour@linux.vnet.ibm.com> <1503007519-26777-18-git-send-email-ldufour@linux.vnet.ibm.com> <cd2f451d-c6d6-1ff5-b7d9-d3d0937ae056@linux.vnet.ibm.com>
Date: Tue, 22 Aug 2017 11:46:05 +1000
Message-ID: <87o9r8bciq.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, Laurent Dufour <ldufour@linux.vnet.ibm.com>, paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

Anshuman Khandual <khandual@linux.vnet.ibm.com> writes:

> On 08/18/2017 03:35 AM, Laurent Dufour wrote:
>> Add a new software event to count succeeded speculative page faults.
>> 
>> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
>
> Should be merged with the next patch.

No it shouldn't.

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
