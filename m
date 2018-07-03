Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 24D8D6B0008
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 07:43:42 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id ba8-v6so1112166plb.4
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 04:43:42 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z127-v6si947403pgb.455.2018.07.03.04.43.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 04:43:40 -0700 (PDT)
Date: Tue, 3 Jul 2018 13:42:41 +0200
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 4.16 234/279] x86/pkeys/selftests: Adjust the self-test
 to fresh distros that export the pkeys ABI
Message-ID: <20180703114241.GA19730@kroah.com>
References: <20180618080608.851973560@linuxfoundation.org>
 <20180618080618.495174114@linuxfoundation.org>
 <fa4b973b-6037-eaef-3a63-09e8ca638527@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fa4b973b-6037-eaef-3a63-09e8ca638527@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-kernel@vger.kernel.org, stable@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, akpm@linux-foundation.org, dave.hansen@intel.com, linux-mm@kvack.org, linuxram@us.ibm.com, mpe@ellerman.id.au, shakeelb@google.com, shuah@kernel.org, Ingo Molnar <mingo@kernel.org>, Sasha Levin <alexander.levin@microsoft.com>

On Tue, Jul 03, 2018 at 01:36:43PM +0200, Vlastimil Babka wrote:
> On 06/18/2018 10:13 AM, Greg Kroah-Hartman wrote:
> > 4.16-stable review patch.  If anyone has any objections, please let me know.
> 
> So I was wondering, why backport such a considerable number of
> *selftests* to stable, given the stable policy? Surely selftests don't
> affect the kernel itself breaking for users?

These came in as part of Sasha's "backport fixes" tool.  It can't hurt
to add selftest fixes/updates to stable kernels, as for some people,
they only run the selftests for the specific kernel they are building.
While others run selftests for the latest kernel on older kernels, both
of which are valid ways of testing.

thanks,

greg k-h
