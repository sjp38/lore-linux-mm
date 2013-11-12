Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id B819F6B0044
	for <linux-mm@kvack.org>; Tue, 12 Nov 2013 12:35:28 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id kl14so1297633pab.39
        for <linux-mm@kvack.org>; Tue, 12 Nov 2013 09:35:28 -0800 (PST)
Received: from psmtp.com ([74.125.245.147])
        by mx.google.com with SMTP id ar5si20276383pbd.302.2013.11.12.09.35.26
        for <linux-mm@kvack.org>;
        Tue, 12 Nov 2013 09:35:27 -0800 (PST)
Message-ID: <528266A9.2040901@sr71.net>
Date: Tue, 12 Nov 2013 09:34:33 -0800
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [Results] [RFC PATCH v4 00/40] mm: Memory Power Management
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com> <52437128.7030402@linux.vnet.ibm.com> <20130925164057.6bbaf23bdc5057c42b2ab010@linux-foundation.org> <52442F6F.5020703@linux.vnet.ibm.com> <5281E09B.3060303@linux.vnet.ibm.com>
In-Reply-To: <5281E09B.3060303@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: mgorman@suse.de, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, amit.kachhap@linaro.org, thomas.abraham@linaro.org, markgross@thegnar.org

On 11/12/2013 12:02 AM, Srivatsa S. Bhat wrote:
> I performed experiments on an IBM POWER 7 machine and got actual power-savings
> numbers (upto 2.6% of total system power) from this patchset. I presented them
> at the Kernel Summit but forgot to post them on LKML. So here they are:

"upto"?  What was it, actually?  Essentially what you've told us here is
that you have a patch that tries to do some memory power management and
that it accomplishes that.  But, to what degree?

Was your baseline against a kernel also booted with numa=fake=1, or was
it a kernel booted normally?

1. What is the theoretical power savings from memory?
2. How much of the theoretical numbers can your patch reach?
3. What is the performance impact?  Does it hurt ebizzy?

You also said before:
> On page 40, the paper shows the power-consumption breakdown for an IBM p670
> machine, which shows that as much as 40% of the system energy is consumed by
> the memory sub-system in a mid-range server.

2.6% seems pretty awful for such an invasive patch set if you were
expecting 40%.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
