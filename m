Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A57366B004D
	for <linux-mm@kvack.org>; Thu, 19 Nov 2009 10:26:11 -0500 (EST)
Date: Thu, 19 Nov 2009 15:25:48 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [BUG]2.6.27.y some contents lost after writing to mmaped file
Message-ID: <20091119152548.GA22232@n2100.arm.linux.org.uk>
References: <2df346410911151938r1eb5c5e4q9930ac179d61ef01@mail.gmail.com> <20091117015655.GA8683@suse.de> <20091117123622.GI27677@think> <20091117190635.GB31105@duck.suse.cz> <20091118221756.367c005e@ustc>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091118221756.367c005e@ustc>
Sender: owner-linux-mm@kvack.org
To: JiSheng Zhang <jszhang3@gmail.com>
Cc: Jan Kara <jack@suse.cz>, Greg KH <gregkh@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org, Chris Mason <chris.mason@oracle.com>, linux-arm@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 18, 2009 at 10:17:56PM +0800, JiSheng Zhang wrote:
> I forget to mention that the test were done on an arm board with 64M ram. 
> I have tested fsx-linux again on pc, it seems that failure go away.

Could provide a full bug report please, as in:

- CPU type
- is it a SMP CPU
- are you running a SMP kernel
- board type

All the above can be provided by supplying the kernel boot messages
(preferred)

- the storage peripheral being used for this test
- is DMA being used for this periperal
- any additional block layers (eg, lvm, dm, md)
- filesystem type

Plus, please cc suspected ARM problems to the ARM _kernel_ mailing list.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
