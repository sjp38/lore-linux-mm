Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 43BF56B0007
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 14:37:15 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id h11so10245234pfn.0
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 11:37:15 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t132sor2706042pgb.433.2018.03.05.11.37.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Mar 2018 11:37:14 -0800 (PST)
Subject: Re: [PATCH 2/7] genalloc: selftest
References: <20180228200620.30026-1-igor.stoppa@huawei.com>
 <20180228200620.30026-3-igor.stoppa@huawei.com>
From: J Freyensee <why2jjj.linux@gmail.com>
Message-ID: <488cc366-bd10-425c-ef62-ce8536e3c62a@gmail.com>
Date: Mon, 5 Mar 2018 11:37:10 -0800
MIME-Version: 1.0
In-Reply-To: <20180228200620.30026-3-igor.stoppa@huawei.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>, david@fromorbit.com, willy@infradead.org, keescook@chromium.org, mhocko@kernel.org
Cc: labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com


> +
> +/*
> + * In case of failure of any of these tests, memory corruption is almost
> + * guarranteed; allowing the boot to continue means risking to corrupt
> + * also any filesystem/block device accessed write mode.
> + * Therefore, BUG_ON() is used, when testing.
> + */
> +
> +

I like the explanation; good background info on why something is 
implemented the way it is :-).

Reviewed-by: Jay Freyensee <why2jjj.linux@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
