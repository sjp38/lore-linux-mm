Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id 12AD56B0032
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 16:26:08 -0500 (EST)
Received: by mail-we0-f170.google.com with SMTP id x3so4207015wes.1
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 13:26:07 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id ho6si8557114wjb.152.2015.01.22.13.26.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 22 Jan 2015 13:26:06 -0800 (PST)
Date: Thu, 22 Jan 2015 22:25:39 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v7 0/7] Support Write-Through mapping on x86
In-Reply-To: <1421342920.2493.8.camel@misato.fc.hp.com>
Message-ID: <alpine.DEB.2.11.1501222225000.5526@nanos>
References: <1420577392-21235-1-git-send-email-toshi.kani@hp.com> <1421342920.2493.8.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: hpa@zytor.com, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com

On Thu, 15 Jan 2015, Toshi Kani wrote:

> Hi Ingo, Peter, Thomas,
> 
> Is there anything else I need to do for accepting this patchset? 

You might hand me some spare time for reviewing it :)

It's on my list.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
