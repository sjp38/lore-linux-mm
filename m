Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 633816B0258
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 13:21:06 -0500 (EST)
Received: by wmec201 with SMTP id c201so40953931wme.1
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 10:21:06 -0800 (PST)
Received: from Galois.linutronix.de (linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id wo7si5817824wjb.160.2015.12.08.10.21.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 08 Dec 2015 10:21:05 -0800 (PST)
Date: Tue, 8 Dec 2015 19:20:15 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 22/34] x86, pkeys: dump PTE pkey in /proc/pid/smaps
In-Reply-To: <20151204011454.9E6D5829@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.11.1512081919580.3595@nanos>
References: <20151204011424.8A36E365@viggo.jf.intel.com> <20151204011454.9E6D5829@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com

On Thu, 3 Dec 2015, Dave Hansen wrote:
> The protection key can now be just as important as read/write
> permissions on a VMA.  We need some debug mechanism to help
> figure out if it is in play.  smaps seems like a logical
> place to expose it.
> 
> arch/x86/kernel/setup.c is a bit of a weirdo place to put
> this code, but it already had seq_file.h and there was not
> a much better existing place to put it.
> 
> We also use no #ifdef.  If protection keys is .config'd out
> we will get the same function as if we used the weak generic
> function.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
