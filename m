Message-ID: <4007B03C.4090106@gmx.de>
Date: Fri, 16 Jan 2004 10:34:52 +0100
From: "Prakash K. Cheemplavam" <PrakashKC@gmx.de>
MIME-Version: 1.0
Subject: Re: 2.6.1-mm4
References: <20040115225948.6b994a48.akpm@osdl.org>
In-Reply-To: <20040115225948.6b994a48.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I just gave it a try and the locking-up issue went worse with this 
kernel. Now even without APIC the kernel locks up quite fast on my 
nforce2. Very easy method (for me) was to copy a large file from CD-ROM 
(at least now mounting CDs works again, in contrast to mm2) to HD and 
machine locks-up. Sorry, no stack backtrace yet and no log entry, but 
I'll try to do what I can.

Prakash
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
