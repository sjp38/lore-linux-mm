Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id E6DF56B0078
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 17:21:36 -0400 (EDT)
Message-ID: <4FDA55A6.2030706@redhat.com>
Date: Thu, 14 Jun 2012 17:20:38 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: bugs in page colouring code
References: <20120613152936.363396d5@cuia.bos.redhat.com> <20120614103627.GA25940@aftab.osrc.amd.com> <4FD9DFCE.1070609@redhat.com> <4FDA5087.7090606@linux.intel.com> <4FDA519F.4080204@redhat.com> <4FDA5413.9080400@linux.intel.com>
In-Reply-To: <4FDA5413.9080400@linux.intel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@linux.intel.com>
Cc: Borislav Petkov <bp@amd64.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, sjhill@mips.com, ralf@linux-mips.org, Rob Herring <rob.herring@calxeda.com>, Russell King <rmk+kernel@arm.linux.org.uk>, Nicolas Pitre <nico@linaro.org>

On 06/14/2012 05:13 PM, H. Peter Anvin wrote:

> I am much more skeptical to disabling page coloring in the !PF_RANDOMIZE
> case when no address hint is proposed.  I would like to at least try
> running without it, perhaps with a chicken bit in a sysctl.

Agreed, it is hard to imagine a program that passes
address 0 to mmap, yet breaks when it gets a coloured
page address back...

I'll leave that bit of code untouched for now, we can
play with it later.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
