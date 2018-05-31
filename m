Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 884A16B0007
	for <linux-mm@kvack.org>; Thu, 31 May 2018 11:36:31 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id q129-v6so1177670oic.9
        for <linux-mm@kvack.org>; Thu, 31 May 2018 08:36:31 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id l56-v6si5213538otb.35.2018.05.31.08.36.29
        for <linux-mm@kvack.org>;
        Thu, 31 May 2018 08:36:30 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: Re: Report A bug of PTE attribute set for mprotect
References: <2018052919455555635434@amlogic.com>
Date: Thu, 31 May 2018 16:36:27 +0100
In-Reply-To: <2018052919455555635434@amlogic.com> (Tao Zeng's message of "Tue,
	29 May 2018 19:47:58 +0800")
Message-ID: <87tvqn96ro.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Tao.Zeng" <Tao.Zeng@amlogic.com>
Cc: mgorman <mgorman@suse.de>, tglx <tglx@linutronix.de>, "dan.j.williams" <dan.j.williams@intel.com>, "nadav.amit" <nadav.amit@gmail.com>, khandual <khandual@linux.vnet.ibm.com>, "zi.yan" <zi.yan@cs.rutgers.edu>, n-horiguchi <n-horiguchi@ah.jp.nec.com>, "henry.willard" <henry.willard@oracle.com>, jglisse <jglisse@redhat.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

Tao.Zeng <Tao.Zeng@amlogic.com> writes:

[...]

> Background of this problem:

> Our kernel version is 3.14.29,

Are you able to reproduce the problem on a recent upstream kernel?

3.14.29 is more than three years old and the problem you see might have
been fixed since then.

Thanks,
Punit
