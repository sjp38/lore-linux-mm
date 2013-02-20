Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 928246B0005
	for <linux-mm@kvack.org>; Tue, 19 Feb 2013 20:38:46 -0500 (EST)
Message-ID: <51242908.2050308@huawei.com>
Date: Wed, 20 Feb 2013 09:38:16 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH V3] ia64/mm: fix a bad_page bug when crash kernel booting
References: <51074786.5030007@huawei.com> <1359995565.7515.178.camel@mfleming-mobl1.ger.corp.intel.com> <51131248.3080203@huawei.com> <5113450C.1080109@huawei.com> <CA+8MBbKuBheEj9t8whJBc=S7NdxCF8MvuD2Ajm7suP=7JC01fg@mail.gmail.com>
In-Reply-To: <CA+8MBbKuBheEj9t8whJBc=S7NdxCF8MvuD2Ajm7suP=7JC01fg@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@gmail.com>
Cc: Matt Fleming <matt.fleming@intel.com>, fenghua.yu@intel.com, Liujiang <jiang.liu@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-efi@vger.kernel.org, linux-mm@kvack.org, Hanjun Guo <guohanjun@huawei.com>, WuJianguo <wujianguo@huawei.com>

On 2013/2/20 5:56, Tony Luck wrote:

> Foolishly sent an earlier reply from Outlook which appears
> to have mangled/lost it. Trying again ...
> 
>> In efi_init() memory aligns in IA64_GRANULE_SIZE(16M). If set "crashkernel=1024M-:600M"
> 
> Is this where the real problem begins?  Should we insist that users

Hi Tony, I think this is the real problem begins and it only appears when use Sparse-Memory.

> provide crashkernel
> parameters rounded to GRANULE boundaries?
> 

Seems like a good idea, should we modify "\linux\Documentation\kernel-parameters.txt"?

Thanks,
Xishi Qiu

> -Tony
>  


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
