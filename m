Received: from delhi.clic.cs.columbia.edu (IDENT:BS2jUjiYmPW0Sw5cyov7o+px6mKm6FIw@delhi.clic.cs.columbia.edu [128.59.15.41])
	by cs.columbia.edu (8.12.9/8.12.9) with ESMTP id h5SHsQkN020690
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 28 Jun 2003 13:54:26 -0400 (EDT)
Received: from delhi.clic.cs.columbia.edu (IDENT:KvPvAvXEd8jRHJ/EVA4TShksQSA/ImjO@localhost [127.0.0.1])
	by delhi.clic.cs.columbia.edu (8.12.9/8.12.9) with ESMTP id h5SHsQEu010961
	for <linux-mm@kvack.org>; Sat, 28 Jun 2003 13:54:26 -0400
Received: from localhost (rra2002@localhost)
	by delhi.clic.cs.columbia.edu (8.12.9/8.12.9/Submit) with ESMTP id h5SHsQf6010957
	for <linux-mm@kvack.org>; Sat, 28 Jun 2003 13:54:26 -0400
Date: Sat, 28 Jun 2003 13:54:26 -0400 (EDT)
From: "Raghu R. Arur" <rra2002@cs.columbia.edu>
Subject: i_writecount doubt
Message-ID: <Pine.LNX.4.44.0306281353370.8819-100000@delhi.clic.cs.columbia.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


182  if (file) {
183  struct inode *inode = file->f_dentry->d_inode;
184  get_file(file);
185  if (tmp->vm_flags & VM_DENYWRITE)
186  atomic_dec(&inode->i_writecount);
187

  I was looking at the code of dup_mmap() in fork.c. I didnt understand
something over here. The code above is checking whether the vm_area of the
parent that the new process (child process)is copying, has read-only
permission or read-write
permission. If it has read-only permission then the inode's i_writecount
is decremented. I saw in the vm documentation that if i_writecount is
negative then it is read-only and if it is positive then it is positive.
According to my understanding the inode data that we are accessing is
global. So some processes might have read-only access
to the file and some have read-write access to the file. So how can we
decide whether the process has the correct access just by seeing the value
of i_writecount of the inode. OR am i missing something over here.

  Can anyone please explain whats happening over here.

 thanks,
raghu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
