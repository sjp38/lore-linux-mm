Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 46BD06B003D
	for <linux-mm@kvack.org>; Wed,  6 May 2009 08:20:49 -0400 (EDT)
Message-ID: <4A0180AB.20108@redhat.com>
Date: Wed, 06 May 2009 08:20:59 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] x86: 46 bit PAE support
References: <20090505172856.6820db22@cuia.bos.redhat.com> <4A00ED83.1030700@zytor.com>
In-Reply-To: <4A00ED83.1030700@zytor.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, mingo@redhat.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

H. Peter Anvin wrote:
> Rik van Riel wrote:
>> Testing: booted it on an x86-64 system with 6GB RAM.  Did you really think
>> I had access to a system with 64TB of RAM? :)
> 
> No, but it would be good if we could test it under Qemu or KVM with an
> appropriately set up sparse memory map.

I don't have a system with 1TB either, which is how much space
the memmap[] would take...

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
