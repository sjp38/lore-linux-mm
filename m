Received: from localhost (localhost.localdomain [127.0.0.1])
	by einstein.tteng.com.br (Postfix) with ESMTP id CBB9512004A
	for <linux-mm@kvack.org>; Wed, 21 Jul 2004 13:42:01 -0300 (BRT)
Received: from [192.168.0.141] (luciano.tteng.com.br [192.168.0.141])
	by einstein.tteng.com.br (Postfix) with ESMTP id C5495120049
	for <linux-mm@kvack.org>; Wed, 21 Jul 2004 13:42:00 -0300 (BRT)
Message-ID: <40FE9D66.3070709@tteng.com.br>
Date: Wed, 21 Jul 2004 13:44:22 -0300
From: "Luciano A. Stertz" <luciano@tteng.com.br>
MIME-Version: 1.0
Subject: [Fwd: vma list in struct address_space]
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

	Hi,
		I sent this message to kernelnewbies but receive no replay. May you 
please help me?

	Thanks,
		Luciano

====================================================

	I have a doubt about the address_space struct.
	I understand that struct address_space contains lists of the virtual
memory area instances that refers to the inode controlled by this
address_space.
	Up to kernel 2.6.6, it was clear to me from the struct declaration that
there were two lists, i_mmap was the list of private (created with
MAP_PRIVATE) mappings and i_mmap_shared the list of shared (created with
MAP_SHARED).
	On kernel 2.6.7, however, I couldn't undestand the lists:

         struct prio_tree_root   i_mmap;         /* tree of private
mappings */
         struct list_head        i_mmap_nonlinear;/*list VM_NONLINEAR
mappings */

	i_mmap seems to be still listing private mappings, but i_mmap_shared
was removed and i_mmap_nonlinear added.
	If I create a shared linear mapping, will it be kept in any of these lists?
	Or maybe the i_mmap comment is misleading, and now i_mmap maps linear vmas?

	TIA,
		Luciano Stertz

-- 
Luciano A. Stertz
luciano@tteng.com.br
T&T Engenheiros Associados Ltda
http://www.tteng.com.br
Fone/Fax (51) 3224 8425

--
Kernelnewbies: Help each other learn about the Linux kernel.
Archive:       http://mail.nl.linux.org/kernelnewbies/
FAQ:           http://kernelnewbies.org/faq/


-- 
Luciano A. Stertz
luciano@tteng.com.br
T&T Engenheiros Associados Ltda
http://www.tteng.com.br
Fone/Fax (51) 3224 8425
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
