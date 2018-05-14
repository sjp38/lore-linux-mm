Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0D30F6B000A
	for <linux-mm@kvack.org>; Mon, 14 May 2018 04:47:46 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id r23-v6so9147434wrc.2
        for <linux-mm@kvack.org>; Mon, 14 May 2018 01:47:45 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k63-v6sor3854836wrc.17.2018.05.14.01.47.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 May 2018 01:47:44 -0700 (PDT)
Date: Mon, 14 May 2018 10:47:41 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 00/13] [v4] x86, pkeys: two protection keys bug fixes
Message-ID: <20180514084741.GA7094@gmail.com>
References: <20180509171336.76636D88@viggo.jf.intel.com>
 <20180514082918.GA21574@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180514082918.GA21574@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxram@us.ibm.com, tglx@linutronix.de, dave.hansen@intel.com, mpe@ellerman.id.au, akpm@linux-foundation.org, shuah@kernel.org, shakeelb@google.com


* Ingo Molnar <mingo@kernel.org> wrote:

> So this series is looking good to me in principle, but trying to build it I got 
> warnings and errors - see the build log below.
> 
> Note that this is on a box with "Ubuntu 18.04 LTS (Bionic Beaver)".

So it turns out that the build errors already exist without the series applied, so 
it must be some interaction between the pkeys self-tests and latest Ubuntu.

Thanks,

	Ingo
