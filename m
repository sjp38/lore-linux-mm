Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C30296B004F
	for <linux-mm@kvack.org>; Wed,  6 May 2009 08:30:07 -0400 (EDT)
Date: Wed, 6 May 2009 14:30:30 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] x86: 46 bit PAE support
Message-ID: <20090506123030.GW25203@elte.hu>
References: <20090505172856.6820db22@cuia.bos.redhat.com> <4A00ED83.1030700@zytor.com> <4A0180AB.20108@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A0180AB.20108@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, mingo@redhat.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>


* Rik van Riel <riel@redhat.com> wrote:

> H. Peter Anvin wrote:
>> Rik van Riel wrote:
>>> Testing: booted it on an x86-64 system with 6GB RAM.  Did you really think
>>> I had access to a system with 64TB of RAM? :)
>>
>> No, but it would be good if we could test it under Qemu or KVM with an
>> appropriately set up sparse memory map.
>
> I don't have a system with 1TB either, which is how much space
> the memmap[] would take...

Not if the physical layout is sparse. I.e. something silly like:

  BIOS-e820: 0000000100000000 - 0000000140000000 (usable)
  BIOS-e820: 0000200000000000 - 0000200040000000 (usable)

Which is 1GB of RAM at 4GB physical offset, and another 1GB of RAM 
at 32 TB physical offset. Takes two gigs of real RAM and a kernel 
modified with your patch, to not get confused by this :-)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
