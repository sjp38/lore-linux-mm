Date: Sun, 9 Jun 2002 18:12:10 +0530
From: Abhishek Nayani <abhi@kernelnewbies.org>
Subject: Doubt in dup_mmap()
Message-ID: <20020609124210.GA2432@SandStorm.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

	In the function dup_mmap() in kernel/fork.c, 

	file = tmp->vm_file;
	if (file) {
		struct inode *inode = file->f_dentry->d_inode;
		get_file(file);
		if(tmp->vm_flags & VM_DENYWRITE)
			atomic_dec(&inode->i_writecount);

	After this piece of code, shouldn't there be :
	
		else
			atomic_inc(&inode->i_writecount);

	as this is a read-write mapping ?
	
				
					Bye,
						Abhi.
	
Linux Kernel Documentation Project
http://freesoftware.fsf.org/lkdp

	
--------------------------------------------------------------------------------
Those who cannot remember the past are condemned to repeat it - George Santayana
--------------------------------------------------------------------------------
                          Home Page: http://www.abhi.tk
-----BEGIN GEEK CODE BLOCK------------------------------------------------------
GCS d+ s:- a-- C+++ UL P+ L+++ E- W++ N+ o K- w--- O-- M- V- PS PE Y PGP 
t+ 5 X+ R- tv+ b+++ DI+ D G e++ h! !r y- 
------END GEEK CODE BLOCK-------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
