Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 4CEE16B0031
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 14:15:51 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id g10so2082787pdj.0
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 11:15:51 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id sr7si6723522pab.202.2014.06.19.11.15.50
        for <linux-mm@kvack.org>;
        Thu, 19 Jun 2014 11:15:50 -0700 (PDT)
Date: Thu, 19 Jun 2014 11:13:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: arch/ia64/include/uapi/asm/fcntl.h:9:41: error: 'PER_LINUX32'
 undeclared
Message-Id: <20140619111328.f4c93216.akpm@linux-foundation.org>
In-Reply-To: <CA+8MBbKK6d+9D2SdebNavYPf9ZyjkCyqj8gvvq8wxPjpWs9Opg@mail.gmail.com>
References: <53a21a3e.1HJ5drRU6UL26Oem%fengguang.wu@intel.com>
	<alpine.DEB.2.02.1406181607490.22789@chino.kir.corp.google.com>
	<20140618163013.6e8434a9bab01b46a7531ed4@linux-foundation.org>
	<CA+8MBbKK6d+9D2SdebNavYPf9ZyjkCyqj8gvvq8wxPjpWs9Opg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@gmail.com>
Cc: David Rientjes <rientjes@google.com>, kbuild test robot <fengguang.wu@intel.com>, Will Woods <wwoods@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>, kbuild-all@01.org

On Thu, 19 Jun 2014 09:25:42 -0700 Tony Luck <tony.luck@gmail.com> wrote:

> On Wed, Jun 18, 2014 at 4:30 PM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
> > ia64 allmodconfig has other problems in 3.15:
> >
> > In file included from drivers/nfc/pn544/i2c.c:30:
> > include/linux/unaligned/access_ok.h:7: error: redefinition of 'get_unaligned_le16'
> 
> I don't regularly build allmodconfig ... so this stuff slips by.  It's
> hard to build up
> enthusiasm for making a NFC driver work on ia64.  I don't see a lot of people
> pulling a 200lb 4U server off the rack and hauling it to the subway so they can
> buy a ticket by bumping it against the ticket machine.

I expect this is a snafu in the header files, not nfc..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
