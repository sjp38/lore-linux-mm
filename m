Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 6A0EC6B0031
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 19:30:16 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id ey11so1231631pad.40
        for <linux-mm@kvack.org>; Wed, 18 Jun 2014 16:30:16 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id si5si3763711pab.41.2014.06.18.16.30.15
        for <linux-mm@kvack.org>;
        Wed, 18 Jun 2014 16:30:15 -0700 (PDT)
Date: Wed, 18 Jun 2014 16:30:13 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: arch/ia64/include/uapi/asm/fcntl.h:9:41: error: 'PER_LINUX32'
 undeclared
Message-Id: <20140618163013.6e8434a9bab01b46a7531ed4@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.02.1406181607490.22789@chino.kir.corp.google.com>
References: <53a21a3e.1HJ5drRU6UL26Oem%fengguang.wu@intel.com>
	<alpine.DEB.2.02.1406181607490.22789@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: kbuild test robot <fengguang.wu@intel.com>, Will Woods <wwoods@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>, kbuild-all@01.org, Tony Luck <tony.luck@gmail.com>

On Wed, 18 Jun 2014 16:09:26 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> Yay for build errors reported six weeks later and after 3.15 had been 
> released.

ia64 allmodconfig has other problems in 3.15:

In file included from drivers/nfc/pn544/i2c.c:30:
include/linux/unaligned/access_ok.h:7: error: redefinition of 'get_unaligned_le16'
include/linux/unaligned/le_struct.h:6: note: previous definition of 'get_unaligned_le16' was here
include/linux/unaligned/access_ok.h:12: error: redefinition of 'get_unaligned_le32'
include/linux/unaligned/le_struct.h:11: note: previous definition of 'get_unaligned_le32' was here
...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
