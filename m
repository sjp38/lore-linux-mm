Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id E25AB6B0035
	for <linux-mm@kvack.org>; Mon, 14 Jul 2014 16:12:07 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id hz1so1982058pad.8
        for <linux-mm@kvack.org>; Mon, 14 Jul 2014 13:12:07 -0700 (PDT)
Received: from mail-pd0-x229.google.com (mail-pd0-x229.google.com [2607:f8b0:400e:c02::229])
        by mx.google.com with ESMTPS id pj10si4590026pdb.82.2014.07.14.13.12.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 14 Jul 2014 13:12:06 -0700 (PDT)
Received: by mail-pd0-f169.google.com with SMTP id y10so1433740pdj.14
        for <linux-mm@kvack.org>; Mon, 14 Jul 2014 13:12:06 -0700 (PDT)
Date: Mon, 14 Jul 2014 13:10:05 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: vmstat: On demand vmstat workers V8
In-Reply-To: <alpine.DEB.2.11.1407111022320.26485@gentwo.org>
Message-ID: <alpine.LSU.2.11.1407141306150.17828@eggly.anvils>
References: <alpine.DEB.2.11.1407100903130.12483@gentwo.org> <20140711132032.GB26045@localhost.localdomain> <alpine.DEB.2.11.1407110855030.25432@gentwo.org> <20140711135854.GD26045@localhost.localdomain> <alpine.DEB.2.11.1407111016040.26485@gentwo.org>
 <20140711151935.GE26045@localhost.localdomain> <alpine.DEB.2.11.1407111022320.26485@gentwo.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Frederic Weisbecker <fweisbec@gmail.com>, akpm@linux-foundation.org, Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org, peterz@infradead.org

On Fri, 11 Jul 2014, Christoph Lameter wrote:
> On Fri, 11 Jul 2014, Frederic Weisbecker wrote:
> 
> > Maybe just merge both? The whole looks good.
> 
> I hope so. Andrew?

I hope so, too: I know there are idle feckless^Htickless people
eager for it.  I did take the briefest of looks, but couldn't
really find any mm change to ack or otherwise: if Frederic is
happy with it now, seems good to go.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
