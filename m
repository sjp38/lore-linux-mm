Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id C00796B0253
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 06:33:23 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id g139so12399927oic.12
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 03:33:23 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c184si12242108oih.45.2017.11.27.03.33.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Nov 2017 03:33:22 -0800 (PST)
Subject: Re: [RFC] a question about stack size form /proc/pid/task/child
 pid/limits
References: <59AF5A20.2000101@huawei.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <780b9e4e-7405-2266-a589-17a182d7c7da@redhat.com>
Date: Mon, 27 Nov 2017 12:33:18 +0100
MIME-Version: 1.0
In-Reply-To: <59AF5A20.2000101@huawei.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>
Cc: zhong jiang <zhongjiang@huawei.com>

On 09/06/2017 04:14 AM, Xishi Qiu wrote:
> Hi, I find if I use a defined stack size to create a child thread,
> then the max stack size from /proc/pid/task/child pid/limits still
> shows "Max stack size            8388608", it doesn't update to
> the user defined size, is it a problem?

This reflects the maximum stack size of the main thread after execve. 
The size of the stack of the current thread is a separate matter; it can 
be located anywhere in the process image and much smaller or larger than 
the maximum size of the initial stack of the main thread.

Thanks,
Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
