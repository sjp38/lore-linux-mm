Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C08836B0006
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 07:36:46 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c20-v6so825284eds.21
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 04:36:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v6-v6si1124236edb.343.2018.07.03.04.36.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 04:36:45 -0700 (PDT)
Subject: Re: [PATCH 4.16 234/279] x86/pkeys/selftests: Adjust the self-test to
 fresh distros that export the pkeys ABI
References: <20180618080608.851973560@linuxfoundation.org>
 <20180618080618.495174114@linuxfoundation.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <fa4b973b-6037-eaef-3a63-09e8ca638527@suse.cz>
Date: Tue, 3 Jul 2018 13:36:43 +0200
MIME-Version: 1.0
In-Reply-To: <20180618080618.495174114@linuxfoundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org
Cc: stable@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, akpm@linux-foundation.org, dave.hansen@intel.com, linux-mm@kvack.org, linuxram@us.ibm.com, mpe@ellerman.id.au, shakeelb@google.com, shuah@kernel.org, Ingo Molnar <mingo@kernel.org>, Sasha Levin <alexander.levin@microsoft.com>

On 06/18/2018 10:13 AM, Greg Kroah-Hartman wrote:
> 4.16-stable review patch.  If anyone has any objections, please let me know.

So I was wondering, why backport such a considerable number of
*selftests* to stable, given the stable policy? Surely selftests don't
affect the kernel itself breaking for users?

Thanks, Vlastimil
