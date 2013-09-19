Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 57D406B0031
	for <linux-mm@kvack.org>; Thu, 19 Sep 2013 17:42:51 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id wz12so8835634pbc.39
        for <linux-mm@kvack.org>; Thu, 19 Sep 2013 14:42:51 -0700 (PDT)
Received: by mail-lb0-f182.google.com with SMTP id c11so8391006lbj.13
        for <linux-mm@kvack.org>; Thu, 19 Sep 2013 14:42:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <0000014109b8e5db-4b0f577e-c3b4-47fe-b7f2-0e5febbcc948-000000@email.amazonses.com>
References: <00000140e9dfd6bd-40db3d4f-c1be-434f-8132-7820f81bb586-000000@email.amazonses.com>
	<CAOtvUMdfqyg80_9J8AnOaAdahuRYGC-bpemdo_oucDBPguXbVA@mail.gmail.com>
	<0000014109b8e5db-4b0f577e-c3b4-47fe-b7f2-0e5febbcc948-000000@email.amazonses.com>
Date: Thu, 19 Sep 2013 16:42:46 -0500
Message-ID: <CAOtvUMfQcxwrkKUVRVT+HGGJLphppbLD3cb0uztEjydddmRGng@mail.gmail.com>
Subject: Re: RFC vmstat: On demand vmstat threads
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Linux-MM <linux-mm@kvack.org>

On Tue, Sep 10, 2013 at 4:13 PM, Christoph Lameter <cl@linux.com> wrote:

>
> Note: This patch is based on the vmstat patches in Andrew's tree
> to be merged for the 3.12 kernel.

Sorry for being dumb but this patch doesn't apply for me on either
mmotm nor Linus master. What did I miss?

Gilad


-- 
Gilad Ben-Yossef
Chief Coffee Drinker
gilad@benyossef.com
Israel Cell: +972-52-8260388
US Cell: +1-973-8260388
http://benyossef.com

"If you take a class in large-scale robotics, can you end up in a
situation where the homework eats your dog?"
 -- Jean-Baptiste Queru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
