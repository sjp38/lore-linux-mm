Message-ID: <3CF24557.5020405@yahoo.com>
Date: Mon, 27 May 2002 17:40:23 +0300
From: Gery Kahn <gerykahn@yahoo.com>
MIME-Version: 1.0
Subject: per VMA swapping function?
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

In 2.2.x VMA can have custom swapout func (vm_ops->swapout) (in file 
mapping case) which swapping VMA pages to place other than swap partition.
How is it implemented in 2.4.x?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
