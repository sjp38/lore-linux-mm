Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B27E86B0005
	for <linux-mm@kvack.org>; Thu, 11 Aug 2016 05:51:43 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id h186so126019034pfg.2
        for <linux-mm@kvack.org>; Thu, 11 Aug 2016 02:51:43 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id sq1si2488664pab.29.2016.08.11.02.47.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 11 Aug 2016 02:51:43 -0700 (PDT)
Message-ID: <57AC490E.4080204@huawei.com>
Date: Thu, 11 Aug 2016 17:44:46 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: arm64: why set SECTION_SIZE_BITS to 1G size?
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, chenjie6@huawei.com

Hi everyone:
arm64:
SECTION_SIZE_BITS 30 -----1G

The memory hotplug(add_memory -->check_hotplug_memory_range) 
must be aligned with section.So I can not add mem with 64M ...
Can I modify the SECTION_SIZE_BITS to 26?

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
