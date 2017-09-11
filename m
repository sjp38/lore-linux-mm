Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9D1656B0296
	for <linux-mm@kvack.org>; Sun, 10 Sep 2017 20:48:15 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id y29so12470460pff.6
        for <linux-mm@kvack.org>; Sun, 10 Sep 2017 17:48:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b9sor3068719pgs.66.2017.09.10.17.48.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 10 Sep 2017 17:48:14 -0700 (PDT)
Date: Mon, 11 Sep 2017 09:45:23 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v2 00/20] Speculative page faults
Message-ID: <20170911004523.GA2938@jagdpanzerIV.localdomain>
References: <1503007519-26777-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170821022629.GA541@jagdpanzerIV.localdomain>
 <6302a906-221d-c977-4aea-67202eb3d96d@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6302a906-221d-c977-4aea-67202eb3d96d@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On (09/08/17 11:24), Laurent Dufour wrote:
> Hi Sergey,
> 
> I can't see where such a chain could happen.
> 
> I tried to recreate it on top of the latest mm tree, to latest stack output
> but I can't get it.
> How did you raised this one ?

Hi Laurent,

didn't do anything special, the box even wasn't under severe memory
pressure. can re-test your new patch set.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
