Message-ID: <3E36BD6B.6080000@shaolinmicro.com>
Date: Wed, 29 Jan 2003 01:27:07 +0800
From: David Chow <davidchow@shaolinmicro.com>
MIME-Version: 1.0
Subject: dirty pages path in kernel
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

If I do the following to an inode mapping page .

1. Generate a "struct page" from read_cache_page()
2. kmap() the page, do some memset() (Dirty the page)
3. kunmap() and page_cache_release() the page.

Since I didn't change any flags in the struct page, and I don't call to the corresponding commit_write() path. How is this page handled afterwards? Does the kernel will call its corresponding writepage() routine when unmap? Or it will ignore the dirty page as the kernel doesn't detects it. What will happen then? Will I loose any changes to that page data? I'm trying to implement some asynchronous mechasim on purging dirty pages on disk writes. Please give advice.

regards,
David


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
