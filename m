Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f175.google.com (mail-yk0-f175.google.com [209.85.160.175])
	by kanga.kvack.org (Postfix) with ESMTP id 349D3440441
	for <linux-mm@kvack.org>; Fri,  5 Feb 2016 20:49:50 -0500 (EST)
Received: by mail-yk0-f175.google.com with SMTP id z13so67731151ykd.0
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 17:49:50 -0800 (PST)
Received: from mail-yw0-x22c.google.com (mail-yw0-x22c.google.com. [2607:f8b0:4002:c05::22c])
        by mx.google.com with ESMTPS id a187si6514509ywc.277.2016.02.05.17.49.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Feb 2016 17:49:49 -0800 (PST)
Received: by mail-yw0-x22c.google.com with SMTP id h129so66188656ywb.1
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 17:49:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1454722827-15744-1-git-send-email-toshi.kani@hpe.com>
References: <1454722827-15744-1-git-send-email-toshi.kani@hpe.com>
Date: Fri, 5 Feb 2016 17:49:48 -0800
Message-ID: <CAPcyv4hAQMjAndt0YaR6Tpz93=9XHtU10mWLHvypYQmBBeuERQ@mail.gmail.com>
Subject: Re: [PATCH] devm_memremap: Fix error value when memremap failed
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Feb 5, 2016 at 5:40 PM, Toshi Kani <toshi.kani@hpe.com> wrote:
> devm_memremap() returns an ERR_PTR() value in case of error.
> However, it returns NULL when memremap() failed.  This causes
> the caller, such as the pmem driver, to proceed and oops later.
>
> Change devm_memremap() to return ERR_PTR(-ENXIO) when memremap()
> failed.
>
> Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>

Acked-by: Dan Williams <dan.j.williams@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
