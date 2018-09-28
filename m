Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 965A78E0001
	for <linux-mm@kvack.org>; Fri, 28 Sep 2018 10:55:22 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id l8-v6so2754554wme.6
        for <linux-mm@kvack.org>; Fri, 28 Sep 2018 07:55:22 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id b7-v6si1910567wmh.75.2018.09.28.07.55.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 28 Sep 2018 07:55:20 -0700 (PDT)
Date: Fri, 28 Sep 2018 16:55:19 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: x86/mm: Found insecure W+X mapping at address
 (ptrval)/0xc00a0000
In-Reply-To: <c8da5778-3957-2fab-69ea-42f872a5e396@molgen.mpg.de>
Message-ID: <alpine.DEB.2.21.1809281653270.2004@nanos.tec.linutronix.de>
References: <e75fa739-4bcc-dc30-2606-25d2539d2653@molgen.mpg.de> <alpine.DEB.2.21.1809191004580.1468@nanos.tec.linutronix.de> <0922cc1b-ed51-06e9-df81-57fd5aa8e7de@molgen.mpg.de> <alpine.DEB.2.21.1809210045220.1434@nanos.tec.linutronix.de>
 <c8da5778-3957-2fab-69ea-42f872a5e396@molgen.mpg.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Menzel <pmenzel@molgen.mpg.de>
Cc: linux-mm@kvack.org, x86@kernel.org

Paul,

On Mon, 24 Sep 2018, Paul Menzel wrote:
> Am 21.09.2018 um 00:51 schrieb Thomas Gleixner:
> > Can you please apply the patch below, and provide full dmesg of a seabios
> > and a grub boot along with the page table files for each?
> 
> I applied the patch on top of 4.19-rc5. Please find all the files attached.

Sorry for the delay and thanks for the data. A quick diff did not reveal
anything obvious. I'll have a closer look and we probably need more (other)
information to nail that down.

Thanks,

	tglx
