Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 4B6006B014A
	for <linux-mm@kvack.org>; Wed, 11 Jun 2014 05:13:03 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id bj1so1704428pad.17
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 02:13:03 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id ye4si37427539pbc.19.2014.06.11.02.12.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 11 Jun 2014 02:13:02 -0700 (PDT)
Message-ID: <53981D81.5060708@huawei.com>
Date: Wed, 11 Jun 2014 17:12:33 +0800
From: Zhang Zhen <zhenzhang.zhang@huawei.com>
MIME-Version: 1.0
Subject: Proposal to realize hot-add *several sections one time*
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org, laijs@cn.fujitsu.com, sjenning@linux.vnet.ibm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wang Nan <wangnan0@huawei.com>

Hi,

Now we can hot-add memory by

% echo start_address_of_new_memory > /sys/devices/system/memory/probe

Then, [start_address_of_new_memory, start_address_of_new_memory +
memory_block_size] memory range is hot-added.

But we can only hot-add *one section one time* by this way.
Whether we can add an argument on behalf of the count of the sections to add ?
So we can can hot-add *several sections one time*. Just like:

% echo start_address_of_new_memory count_of_sections > /sys/devices/system/memory/probe

Then, [start_address_of_new_memory, start_address_of_new_memory +
count_of_sections * memory_block_size] memory range is hot-added.

If this proposal is reasonable, i will send a patch to realize it.

Any suggestions ?

Best regards.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
