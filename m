Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f50.google.com (mail-oa0-f50.google.com [209.85.219.50])
	by kanga.kvack.org (Postfix) with ESMTP id 2F3D46B0035
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 09:40:54 -0400 (EDT)
Received: by mail-oa0-f50.google.com with SMTP id i11so3683010oag.23
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 06:40:53 -0700 (PDT)
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
        by mx.google.com with ESMTPS id kg1si31615104oeb.77.2014.04.22.06.40.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 06:40:53 -0700 (PDT)
Received: by mail-ob0-f181.google.com with SMTP id gq1so5668921obb.40
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 06:40:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1404220838090.4299@gentwo.org>
References: <000001417f6834f1-32b83f22-8bde-4b9e-b591-bc31329660e4-000000@email.amazonses.com>
	<CAOh2x==yrBdFDcObdz+La0y=jDERj=sxOBMvU-Kk6eGEvvwZQw@mail.gmail.com>
	<alpine.DEB.2.10.1404220838090.4299@gentwo.org>
Date: Tue, 22 Apr 2014 19:10:53 +0530
Message-ID: <CAKohpok8G=SsOje-tS0bU7sp9SWOcnJJoAsKzPE9dN84Tk+kHQ@mail.gmail.com>
Subject: Re: vmstat: On demand vmstat workers V3
From: Viresh Kumar <viresh.kumar@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On 22 April 2014 19:08, Christoph Lameter <cl@linux.com> wrote:
> Sorry no too much other stuff. Would be glad if you could improve on it.
> Should have some time on Friday to look at it.

Really busy with other activities for improving core isolation, doesn't look
like I will get enough time getting this done :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
