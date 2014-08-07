Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 6480F6B0035
	for <linux-mm@kvack.org>; Wed,  6 Aug 2014 21:50:58 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kx10so4438390pab.20
        for <linux-mm@kvack.org>; Wed, 06 Aug 2014 18:50:58 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id gi1si2206568pbd.100.2014.08.06.18.50.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 06 Aug 2014 18:50:57 -0700 (PDT)
Message-ID: <53E2DB4C.3060109@oracle.com>
Date: Wed, 06 Aug 2014 21:50:04 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: vmstat: On demand vmstat workers V8
References: <alpine.DEB.2.11.1407100903130.12483@gentwo.org> <53D31101.8000107@oracle.com> <53DFFD28.2030502@oracle.com> <alpine.DEB.2.11.1408050950390.16902@gentwo.org> <53E159F6.7080603@oracle.com> <alpine.DEB.2.11.1408060908580.4346@gentwo.org>
In-Reply-To: <alpine.DEB.2.11.1408060908580.4346@gentwo.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: akpm@linux-foundation.org, Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org, peterz@infradead.org

On 08/06/2014 10:12 AM, Christoph Lameter wrote:
> On Tue, 5 Aug 2014, Sasha Levin wrote:
> 
>> > I can easily trigger it by cranking up the cpu hotplug code. Just try to
>> > frequently offline and online cpus, it should reproduce quickly.
> Thats what I thought.
> 
> The test was done with this fix applied right?

Nope, I never saw the patch before. Applied it and the problem goes away. Thanks!


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
