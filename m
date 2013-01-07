Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 802CF6B005D
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 07:32:16 -0500 (EST)
Received: by mail-ob0-f171.google.com with SMTP id dn14so17312792obc.30
        for <linux-mm@kvack.org>; Mon, 07 Jan 2013 04:32:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <50EA01BC.2080001@fold.natur.cuni.cz>
References: <50EA01BC.2080001@fold.natur.cuni.cz>
Date: Mon, 7 Jan 2013 20:32:15 +0800
Message-ID: <CAJd=RBCqZj01PPzZnxfYtxJtst6nbpuFG8x2wDhmYk=4XrqCXw@mail.gmail.com>
Subject: Re: linux-3.7.1: OOPS in page_lock_anon_vma
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Mokrejs <mmokrejs@fold.natur.cuni.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Greg KH <gregkh@linuxfoundation.org>, Tejun Heo <tj@kernel.org>

Hello Martin

On Mon, Jan 7, 2013 at 6:59 AM, Martin Mokrejs
<mmokrejs@fold.natur.cuni.cz> wrote:
> time to time. With ondemand governor I had cores in C7 for 50-70% of the time, that was
> a bit better with performance governor but having the two hyperthreaded cores disabled
> reduced the context switches by half, rescheduling interrupts went down by several orders
> of magnitute. So it is crunching at max turbo speed on both cores, temp about 80 oC.
>
Your boxen could be used to cook pizza, and check the
recommended working temperature in the manual please.

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
