Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 57A1D6B00BC
	for <linux-mm@kvack.org>; Tue, 12 Nov 2013 11:40:19 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id hz1so3329347pad.3
        for <linux-mm@kvack.org>; Tue, 12 Nov 2013 08:40:19 -0800 (PST)
Received: from psmtp.com ([74.125.245.151])
        by mx.google.com with SMTP id yl8si20496621pab.147.2013.11.12.08.40.17
        for <linux-mm@kvack.org>;
        Tue, 12 Nov 2013 08:40:18 -0800 (PST)
Date: Tue, 12 Nov 2013 16:40:15 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: vmstat: On demand vmstat workers V3
In-Reply-To: <000001417f6834f1-32b83f22-8bde-4b9e-b591-bc31329660e4-000000@email.amazonses.com>
Message-ID: <000001424d2f4f0f-a7611966-71b6-432a-9f2e-adaa2c04f324-000000@email.amazonses.com>
References: <000001417f6834f1-32b83f22-8bde-4b9e-b591-bc31329660e4-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hmmm... This has been sitting there for over a month. What I can I do to
to make progress on merging this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
