From: Nikita Danilov <Nikita@Namesys.COM>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16252.23200.511369.466054@laputa.namesys.com>
Date: Thu, 2 Oct 2003 21:04:32 +0400
Subject: Re: 2.6.0-test6-mm2
In-Reply-To: <20031002022341.797361bc.akpm@osdl.org>
References: <20031002022341.797361bc.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@parcelfarce.linux.theplanet.co.uk
List-ID: <linux-mm.kvack.org>

Andrew Morton writes:
 > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.0-test6/2.6.0-test6-mm2/
 > 
 > . A large series of VFS patches from Al Viro which replace usage of
 >   file->f_dentry->d_inode->i_mapping with the new file->f_mapping.
 > 
 >   This is mainly so we can get disk hot removal right.

What consequences does this have for (out-of-the-tree) file systems,
beyond s/->f_dentry->d_inode->i_mapping/->f_mapping/g ?

 > 

Nikita.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
