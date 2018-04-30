Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 946136B0003
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 11:30:46 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b64so8025559pfl.13
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 08:30:46 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id s6-v6si6514427pgr.369.2018.04.30.08.30.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Apr 2018 08:30:45 -0700 (PDT)
Subject: Re: [PATCH 0/9] [v3] x86, pkeys: two protection keys bug fixes
References: <20180427174527.0031016C@viggo.jf.intel.com>
 <20180428070553.yjlt22sb6ntcaqnc@gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <a176ae33-eb01-d275-f372-a33829e865a7@intel.com>
Date: Mon, 30 Apr 2018 08:30:43 -0700
MIME-Version: 1.0
In-Reply-To: <20180428070553.yjlt22sb6ntcaqnc@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxram@us.ibm.com, tglx@linutronix.de, mpe@ellerman.id.au, akpm@linux-foundation.org, shuah@kernel.org, shakeelb@google.com

On 04/28/2018 12:05 AM, Ingo Molnar wrote:
> In the above kernel that was missing the PROT_EXEC fix I was repeatedly running 
> the 64-bit and 32-bit testcases as non-root and as root as well, until I got a 
> hang in the middle of a 32-bit test running as root:
> 
>   test  7 PASSED (iteration 19)
>   test  8 PASSED (iteration 19)
>   test  9 PASSED (iteration 19)
> 
>   < test just hangs here >

For the hang, there is a known issue with the use of printf() in the
signal handler and a resulting deadlock.  I *thought* there was a patch
merged to fix this from Ram Pai or one of the other IBM folks.
