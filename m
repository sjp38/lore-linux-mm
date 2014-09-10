Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id 307096B003C
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 14:31:02 -0400 (EDT)
Received: by mail-la0-f41.google.com with SMTP id s18so10393158lam.0
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 11:31:01 -0700 (PDT)
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
        by mx.google.com with ESMTPS id j4si22469864lbn.98.2014.09.10.11.31.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 11:31:00 -0700 (PDT)
Received: by mail-la0-f44.google.com with SMTP id mc6so6583774lab.31
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 11:31:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1410367910-6026-7-git-send-email-toshi.kani@hp.com>
References: <1410367910-6026-1-git-send-email-toshi.kani@hp.com> <1410367910-6026-7-git-send-email-toshi.kani@hp.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 10 Sep 2014 11:30:40 -0700
Message-ID: <CALCETrVnHg0X=R23qyiPtxYs3knHaXq65L0Jw_1oY4=gX5kpXQ@mail.gmail.com>
Subject: Re: [PATCH v2 6/6] x86, pat: Update documentation for WT changes
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Juergen Gross <jgross@suse.com>, Stefan Bader <stefan.bader@canonical.com>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Yigal Korman <yigal@plexistor.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On Wed, Sep 10, 2014 at 9:51 AM, Toshi Kani <toshi.kani@hp.com> wrote:
> +Drivers may map the entire NV-DIMM range with ioremap_cache and then change
> +a specific range to wt with set_memory_wt.

That's mighty specific :)

It's also not all that informative.  Are you supposed to set the
memory back before iounmapping?  Can you do this with set_memory_wc on
an uncached mapping?

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
