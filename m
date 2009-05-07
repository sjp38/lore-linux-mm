Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 2E8746B003D
	for <linux-mm@kvack.org>; Thu,  7 May 2009 08:45:21 -0400 (EDT)
Date: Thu, 7 May 2009 14:01:30 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] x86: 46 bit PAE support
Message-ID: <20090507120103.GA1497@ucw.cz>
References: <20090505172856.6820db22@cuia.bos.redhat.com> <4A00ED83.1030700@zytor.com> <4A0180AB.20108@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A0180AB.20108@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, mingo@redhat.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wed 2009-05-06 08:20:59, Rik van Riel wrote:
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

Do we really have 1 byte overhead per 64 bytes of RAM?
								Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
