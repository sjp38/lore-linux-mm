Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 1A7F66B0037
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 02:15:38 -0400 (EDT)
Received: by mail-vb0-f45.google.com with SMTP id e15so995751vbg.4
        for <linux-mm@kvack.org>; Thu, 29 Aug 2013 23:15:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130830061413.GA29949@gmail.com>
References: <1377841673-17361-1-git-send-email-bob.liu@oracle.com>
	<20130830061413.GA29949@gmail.com>
Date: Fri, 30 Aug 2013 14:15:36 +0800
Message-ID: <CAA_GA1ea84CvnvzisbhCXmNw+tv9ZQc1drgr8VkER-cpE2G1aQ@mail.gmail.com>
Subject: Re: [PATCH] x86: e820: fix memmap kernel boot parameter
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Aloni <alonid@stratoscale.com>
Cc: Linux-Kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, hpa@linux.intel.com, Yinghai Lu <yinghai@kernel.org>, jacob.shin@amd.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Linux-MM <linux-mm@kvack.org>, Bob Liu <bob.liu@oracle.com>

On Fri, Aug 30, 2013 at 2:14 PM, Dan Aloni <alonid@stratoscale.com> wrote:
> On Fri, Aug 30, 2013 at 01:47:53PM +0800, Bob Liu wrote:
>>[..]
>> Machine2: bootcmdline in grub.cfg "memmap=0x77ffffff$0x880000000", the result of
>> "cat /proc/cmdline" changed to "memmap=0x77ffffffx880000000".
>>
>> I didn't find the root cause, I think maybe grub reserved "$0" as something
>> special.
>> Replace '$' with '%' in kernel boot parameter can fix this issue.
>
> You are correct with the root cause, however I don't think the patch is needed.
>
> In order to bypass grub's variable evaluation you can simply use escaping
> and replace $ with \$ in your grub config.
>

I see, thank you very much!

-- 
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
