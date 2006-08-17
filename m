From: "Abu M. Muttalib" <abum@aftek.com>
Subject: Relation between free() and remove_vm_struct()
Date: Thu, 17 Aug 2006 12:29:15 +0530
Message-ID: <BKEKJNIHLJDCFGDBOHGMKEEHDGAA.abum@aftek.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kernelnewbies@nl.linux.org, linux-newbie@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

In an application I am freeing some memory address, earlier reserved with
malloc.

I have put prints in remove_vm_struct() function in ./mm/mmap.c. For few
calls to free(), there is no corresponding call to remove_vm_struct(). I am
not able to understand why the user space call to free() is not propagated
to kernel, where in the remove_vm_strcut() function should get called.

Please help.

Regards,
Abu.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
