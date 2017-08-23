Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 101CA2803FE
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 18:08:44 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id g131so1492756oic.10
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 15:08:44 -0700 (PDT)
Received: from mail-oi0-x22f.google.com (mail-oi0-x22f.google.com. [2607:f8b0:4003:c06::22f])
        by mx.google.com with ESMTPS id g12si1278164oib.45.2017.08.23.15.08.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 15:08:42 -0700 (PDT)
Received: by mail-oi0-x22f.google.com with SMTP id j144so14609137oib.1
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 15:08:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170823152542.5150-2-boqun.feng@gmail.com>
References: <20170823152542.5150-1-boqun.feng@gmail.com> <20170823152542.5150-2-boqun.feng@gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 23 Aug 2017 15:08:41 -0700
Message-ID: <CAPcyv4gidDb7BMejTiLaQu1KPB8XWzMcp_QeT4NiknPWvdNHxg@mail.gmail.com>
Subject: Re: [PATCH 1/2] nfit: Use init_completion() in acpi_nfit_flush_probe()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boqun Feng <boqun.feng@gmail.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, walken@google.com, Byungchul Park <byungchul.park@lge.com>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Nicholas Piggin <npiggin@gmail.com>, kernel-team@lge.com, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux ACPI <linux-acpi@vger.kernel.org>

On Wed, Aug 23, 2017 at 8:25 AM, Boqun Feng <boqun.feng@gmail.com> wrote:
> There is no need to use COMPLETION_INITIALIZER_ONSTACK() in
> acpi_nfit_flush_probe(), replace it with init_completion().

Now that I see the better version of this patch with the improved
changelog in the -mm tree...

Acked-by: Dan Williams <dan.j.williams@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
