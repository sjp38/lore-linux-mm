Message-Id: <B239D728-5354-42F7-90E6-DE19429D0FBF@kernel.crashing.org>
From: Kumar Gala <galak@kernel.crashing.org>
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0 (Apple Message framework v915)
Subject: reserving a region of highmem at boot time
Date: Tue, 8 Jan 2008 11:46:16 -0600
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Is there a way to mark a page if its in highmem as reserved at boot  
time?

I'm on a ppc32 system and we are trying to ensure that the last page  
of memory isn't used by the kernel.

I see reserve_bootmem but that seems to only deal with low memory.

thanks

- k

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
