Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 47E286B0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2013 16:56:57 -0500 (EST)
Received: by mail-vc0-f182.google.com with SMTP id fl17so4649003vcb.41
        for <linux-mm@kvack.org>; Tue, 19 Feb 2013 13:56:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <5113450C.1080109@huawei.com>
References: <51074786.5030007@huawei.com>
	<1359995565.7515.178.camel@mfleming-mobl1.ger.corp.intel.com>
	<51131248.3080203@huawei.com>
	<5113450C.1080109@huawei.com>
Date: Tue, 19 Feb 2013 13:56:55 -0800
Message-ID: <CA+8MBbKuBheEj9t8whJBc=S7NdxCF8MvuD2Ajm7suP=7JC01fg@mail.gmail.com>
Subject: Re: [PATCH V3] ia64/mm: fix a bad_page bug when crash kernel booting
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Matt Fleming <matt.fleming@intel.com>, fenghua.yu@intel.com, Liujiang <jiang.liu@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-efi@vger.kernel.org, linux-mm@kvack.org, Hanjun Guo <guohanjun@huawei.com>, WuJianguo <wujianguo@huawei.com>

Foolishly sent an earlier reply from Outlook which appears
to have mangled/lost it. Trying again ...

> In efi_init() memory aligns in IA64_GRANULE_SIZE(16M). If set "crashkernel=1024M-:600M"

Is this where the real problem begins?  Should we insist that users
provide crashkernel
parameters rounded to GRANULE boundaries?

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
