Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4DC376B038C
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 12:27:39 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id x63so93924304pfx.7
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 09:27:39 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id z4si5750142pge.359.2017.03.16.09.27.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 09:27:38 -0700 (PDT)
Date: Thu, 16 Mar 2017 09:27:37 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [mmotm] "x86/atomic: move __arch_atomic_add_unless out of line"
 build error
Message-ID: <20170316162737.GJ32070@tassilo.jf.intel.com>
References: <20170316044704.GA729@jagdpanzerIV.localdomain>
 <CACT4Y+asa7rDwjQi_09cYGsgqy0LFRRiCHq3=3t6__VUMLzmXg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+asa7rDwjQi_09cYGsgqy0LFRRiCHq3=3t6__VUMLzmXg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>

> Andi, why did you completely remove __arch_atomic_add_unless() from
> the header? Don't we need at least a declaration there?

Yes the declaration should be there. I'll send a new patch.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
