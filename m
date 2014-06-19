Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f182.google.com (mail-vc0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id 228426B0031
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 12:25:43 -0400 (EDT)
Received: by mail-vc0-f182.google.com with SMTP id il7so2507511vcb.27
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 09:25:42 -0700 (PDT)
Received: from mail-ve0-x233.google.com (mail-ve0-x233.google.com [2607:f8b0:400c:c01::233])
        by mx.google.com with ESMTPS id 6si2629711vct.68.2014.06.19.09.25.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 19 Jun 2014 09:25:42 -0700 (PDT)
Received: by mail-ve0-f179.google.com with SMTP id sa20so2509078veb.24
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 09:25:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140618163013.6e8434a9bab01b46a7531ed4@linux-foundation.org>
References: <53a21a3e.1HJ5drRU6UL26Oem%fengguang.wu@intel.com>
	<alpine.DEB.2.02.1406181607490.22789@chino.kir.corp.google.com>
	<20140618163013.6e8434a9bab01b46a7531ed4@linux-foundation.org>
Date: Thu, 19 Jun 2014 09:25:42 -0700
Message-ID: <CA+8MBbKK6d+9D2SdebNavYPf9ZyjkCyqj8gvvq8wxPjpWs9Opg@mail.gmail.com>
Subject: Re: arch/ia64/include/uapi/asm/fcntl.h:9:41: error: 'PER_LINUX32' undeclared
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, kbuild test robot <fengguang.wu@intel.com>, Will Woods <wwoods@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>, kbuild-all@01.org

On Wed, Jun 18, 2014 at 4:30 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> ia64 allmodconfig has other problems in 3.15:
>
> In file included from drivers/nfc/pn544/i2c.c:30:
> include/linux/unaligned/access_ok.h:7: error: redefinition of 'get_unaligned_le16'

I don't regularly build allmodconfig ... so this stuff slips by.  It's
hard to build up
enthusiasm for making a NFC driver work on ia64.  I don't see a lot of people
pulling a 200lb 4U server off the rack and hauling it to the subway so they can
buy a ticket by bumping it against the ticket machine.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
