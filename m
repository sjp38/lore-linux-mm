Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f177.google.com (mail-yk0-f177.google.com [209.85.160.177])
	by kanga.kvack.org (Postfix) with ESMTP id 3CA7F440441
	for <linux-mm@kvack.org>; Fri,  5 Feb 2016 20:52:04 -0500 (EST)
Received: by mail-yk0-f177.google.com with SMTP id r207so67980349ykd.2
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 17:52:04 -0800 (PST)
Received: from mail-yw0-x235.google.com (mail-yw0-x235.google.com. [2607:f8b0:4002:c05::235])
        by mx.google.com with ESMTPS id w20si6515565yww.51.2016.02.05.17.52.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Feb 2016 17:52:03 -0800 (PST)
Received: by mail-yw0-x235.google.com with SMTP id q190so66164880ywd.3
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 17:52:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAPcyv4hAQMjAndt0YaR6Tpz93=9XHtU10mWLHvypYQmBBeuERQ@mail.gmail.com>
References: <1454722827-15744-1-git-send-email-toshi.kani@hpe.com>
	<CAPcyv4hAQMjAndt0YaR6Tpz93=9XHtU10mWLHvypYQmBBeuERQ@mail.gmail.com>
Date: Fri, 5 Feb 2016 17:52:03 -0800
Message-ID: <CAPcyv4jdSLRxpD0cMmF-gK9CGKbnK4G7Z=P2bVtcUZxgNXFgEA@mail.gmail.com>
Subject: Re: [PATCH] devm_memremap: Fix error value when memremap failed
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Feb 5, 2016 at 5:49 PM, Dan Williams <dan.j.williams@intel.com> wrote:
> On Fri, Feb 5, 2016 at 5:40 PM, Toshi Kani <toshi.kani@hpe.com> wrote:
>> devm_memremap() returns an ERR_PTR() value in case of error.
>> However, it returns NULL when memremap() failed.  This causes
>> the caller, such as the pmem driver, to proceed and oops later.
>>
>> Change devm_memremap() to return ERR_PTR(-ENXIO) when memremap()
>> failed.
>>
>> Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
>> Cc: Dan Williams <dan.j.williams@intel.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>
> Acked-by: Dan Williams <dan.j.williams@intel.com>

Should also go to -stable, I'll add that and include this with some
other fixes I have brewing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
