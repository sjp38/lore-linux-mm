Message-ID: <3C11B5A4.1070708@zytor.com>
Date: Fri, 07 Dec 2001 22:39:32 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: shmfs/tmpfs/vm-fs
References: <01120616545301.04747@hishmoom> <m34rn3jobk.fsf@linux.local>	<01120712372904.00795@hishmoom> <m3vgfjjcfz.fsf@linux.local>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <cr@sap.com>
Cc: lothar.maerkle@gmx.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Rohland wrote:

> 
> It was possible in some 2.3 kernels, but this had to be removed with
> the cleanup :-(
> 


I guess I really still don't understand why.  I certainly can understand 
that it would be highly undesirable if it had to be supported before 
/dev/shm is mounted, but I don't see any reason to allow SysV shared 
memory before mounting /dev/shm.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
