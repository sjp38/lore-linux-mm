Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 867EE6B0033
	for <linux-mm@kvack.org>; Fri,  9 Aug 2013 11:03:02 -0400 (EDT)
Received: by mail-qa0-f47.google.com with SMTP id o19so934507qap.20
        for <linux-mm@kvack.org>; Fri, 09 Aug 2013 08:03:01 -0700 (PDT)
Date: Fri, 9 Aug 2013 11:02:57 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v4 1/2] workqueue: add new schedule_on_cpu_mask() API
Message-ID: <20130809150257.GM20515@mtj.dyndns.org>
References: <5202CEAA.9040204@linux.vnet.ibm.com>
 <201308072335.r77NZJPA022490@farm-0012.internal.tilera.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201308072335.r77NZJPA022490@farm-0012.internal.tilera.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Frederic Weisbecker <fweisbec@gmail.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

Hello, Chris.

On Wed, Aug 07, 2013 at 04:49:44PM -0400, Chris Metcalf wrote:
> This primitive allows scheduling work to run on a particular set of
> cpus described by a "struct cpumask".  This can be useful, for example,
> if you have a per-cpu variable that requires code execution only if the
> per-cpu variable has a certain value (for example, is a non-empty list).

So, this allows scheduling work items on !online CPUs.  Workqueue does
allow scheduling per-cpu work items on offline CPUs if the CPU has
ever been online, but the behavior when scheduling work items on cpu
which has never been online is undefined.  I think the interface at
least needs to verify that the the target cpus have been online,
trigger warning and mask off invalid CPUs otherwise.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
