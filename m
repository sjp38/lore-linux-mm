Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 539D76B0031
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 15:33:42 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id hz1so18968929pad.40
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 12:33:41 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id y1si19067866pbm.64.2014.01.06.12.33.40
        for <linux-mm@kvack.org>;
        Mon, 06 Jan 2014 12:33:41 -0800 (PST)
Date: Mon, 6 Jan 2014 12:33:37 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Is it possible to disable numa_balance after boot?
Message-Id: <20140106123337.c75b78bae6f1258065729ff0@linux-foundation.org>
In-Reply-To: <20140104182235.GT20765@two.firstfloor.org>
References: <CAGz0_-2mkN=KCp=3WkPPVo2_JAtNJAkVpBcwfQ4LVr8R40P=tQ@mail.gmail.com>
	<20140104182235.GT20765@two.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Andreas Hollmann <hollmann@in.tum.de>, linux-numa <linux-numa@vger.kernel.org>, linux-mm@kvack.org, mgorman@suse.de

On Sat, 4 Jan 2014 19:22:35 +0100 Andi Kleen <andi@firstfloor.org> wrote:

> On Sat, Jan 04, 2014 at 06:46:55PM +0100, Andreas Hollmann wrote:
> > Hi,
> > 
> > is possible to turn of numa balancing (introduced in 3.8) in a running kernel?
> 
> 
> I submitted a patch to do it some time ago
> 
> https://lkml.org/lkml/2013/4/24/529
> 
> But it didn't seem to have made it in. Andrew? Mel?

Mel acked it and provided a followup documentation patch.  Redo and
resend, please?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
