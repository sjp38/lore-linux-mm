Date: Mon, 18 Jul 2005 12:36:50 -0700
From: James Washer <washer@trlp.com>
Subject: Re: Question about OOM-Killer
Message-Id: <20050718123650.01a49f31.washer@trlp.com>
In-Reply-To: <20050718122101.751125ef.washer@trlp.com>
References: <20050718122101.751125ef.washer@trlp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Washer <washer@trlp.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Sorry, I should have added... 
	2.6.11.10, 
	x86-64 dual proc (Intel Xeon 3.4GHz)
	6GiB ram
	Intel Corporation 82801EB (ICH5) SATA Controller (rev 0)
	Host: scsi0 Channel: 00 Id: 00 Lun: 00
		Vendor: ATA      Model: Maxtor 6Y160M0   Rev: YAR5
		Type:   Direct-Access                    ANSI SCSI revision: 05
	Host: scsi0 Channel: 00 Id: 01 Lun: 00
		Vendor: ATA      Model: Maxtor 7Y250M0   Rev: YAR5
		Type:   Direct-Access                    ANSI SCSI revision: 05



On Mon, 18 Jul 2005 12:21:01 -0700
James Washer <washer@trlp.com> wrote:

> I'm chasing down a system problem where the DMA memory (x86-64, god knows why it is using DMA memory) drops below the minimum, and the OOM-Killer is fired off.
> 
> It just strikes me odd that the OOM-Killer would be called at all for DMA memory. What's the chance of regaining DMA memory by killing user land processes?
> 
> I'll admit, I know very little about linux VM, so perhaps I'm missing how oom killing can be helpful here. 
> 
>  - jim
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
