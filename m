Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id 952AA6B0003
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 20:36:24 -0500 (EST)
Received: by mail-lb0-f169.google.com with SMTP id pv2so199336371lbb.1
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 17:36:24 -0800 (PST)
Received: from v094114.home.net.pl (v094114.home.net.pl. [79.96.170.134])
        by mx.google.com with SMTP id p66si55470201lfd.22.2016.01.05.17.36.22
        for <linux-mm@kvack.org>;
        Tue, 05 Jan 2016 17:36:22 -0800 (PST)
From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [PATCH v3 UPDATE 09/17] drivers: Initialize resource entry to zero
Date: Wed, 06 Jan 2016 03:07:03 +0100
Message-ID: <4132474.rE6EsOfV8R@vostro.rjw.lan>
In-Reply-To: <1452028537-27365-1-git-send-email-toshi.kani@hpe.com>
References: <1452028537-27365-1-git-send-email-toshi.kani@hpe.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: akpm@linux-foundation.org, bp@alien8.de, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matt Porter <mporter@kernel.crashing.org>, Alexandre Bounine <alexandre.bounine@idt.com>, linux-acpi@vger.kernel.org, linux-parisc@vger.kernel.org, linux-sh@vger.kernel.org

On Tuesday, January 05, 2016 02:15:37 PM Toshi Kani wrote:
> I/O resource descriptor, 'desc' in struct resource, needs to be
> initialized to zero by default.  Some drivers call kmalloc() to
> allocate a resource entry, but does not initialize it to zero by
> memset().  Change these drivers to call kzalloc(), instead.
> 
> Cc: Matt Porter <mporter@kernel.crashing.org>
> Cc: Alexandre Bounine <alexandre.bounine@idt.com>
> Cc: linux-acpi@vger.kernel.org
> Cc: linux-parisc@vger.kernel.org
> Cc: linux-sh@vger.kernel.org
> Acked-by: Simon Horman <horms+renesas@verge.net.au> # sh
> Acked-by: Helge Deller <deller@gmx.de> # parisc
> Signed-off-by: Toshi Kani <toshi.kani@hpe.com>

Acked-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>

for the ACPI part.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
