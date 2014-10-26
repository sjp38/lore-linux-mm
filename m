Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 30BD26B0069
	for <linux-mm@kvack.org>; Sun, 26 Oct 2014 00:31:48 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id fp1so391557pdb.27
        for <linux-mm@kvack.org>; Sat, 25 Oct 2014 21:31:47 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id km1si7665556pbd.22.2014.10.25.21.31.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 25 Oct 2014 21:31:47 -0700 (PDT)
Date: Sat, 25 Oct 2014 21:32:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: UKSM: What's maintainers think about it?
Message-Id: <20141025213201.005762f9.akpm@linux-foundation.org>
In-Reply-To: <CAGqmi77uR2Nems6fE_XM1t3a06OwuqJP-0yOMOQh7KH13vzdzw@mail.gmail.com>
References: <CAGqmi77uR2Nems6fE_XM1t3a06OwuqJP-0yOMOQh7KH13vzdzw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Timofey Titovets <nefelim4ag@gmail.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Sat, 25 Oct 2014 22:25:56 +0300 Timofey Titovets <nefelim4ag@gmail.com> wrote:

> Good time of day, people.
> I try to find 'mm' subsystem specific people and lists, but list
> linux-mm looks dead and mail archive look like deprecated.
> If i must to sent this message to another list or add CC people, let me know.

linux-mm@kvack.org is alive and well.

> If questions are already asked (i can't find activity before), feel
> free to kick me.
> 
> The main questions:
> 1. Somebody test it? I see many reviews about it.
> I already port it to latest linux-next-git kernel and its work without issues.
> http://pastebin.com/6FMuKagS
> (if it matter, i can describe use cases and results, if somebody ask it)
> 
> 2. Developers of UKSM already tried to merge it? Somebody talked with uksm devs?
> offtop: now i try to communicate with dev's on kerneldedup.org forum,
> but i have problems with email verification and wait admin
> registration approval.
> (i already sent questions to
> http://kerneldedup.org/forum/home.php?mod=space&username=xianai ,
> because him looks like team leader)
> 
> 3. I just want collect feedbacks from linux maintainers team, if you
> decide what UKSM not needed in kernel, all other comments (as i
> understand) not matter.
> 
> Like KSM, but better.
> UKSM - Ultra Kernel Samepage Merging
> http://kerneldedup.org/en/projects/uksm/introduction/

It's the first I've heard of it.  No, as far as I know there has been
no attempt to upstream UKSM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
