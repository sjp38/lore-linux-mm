Message-ID: <38C5D132.8F4F5EDD@mandrakesoft.com>
Date: Tue, 07 Mar 2000 23:04:02 -0500
From: Jeff Garzik <jgarzik@mandrakesoft.com>
MIME-Version: 1.0
Subject: Re: remap_page_range problem on 2.3.x
References: <20000308020520.18155.qmail@web1306.mail.yahoo.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Henroid <andy_henroid@yahoo.com>
Cc: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

Andy Henroid wrote:
> 
>                        Name: mmtest.tar.gz
>    mmtest.tar.gz       Type: Unix Tape Archive (application/x-tar)
>                    Encoding: base64
>                 Description: mmtest.tar.gz

Are these the correct test files?

rum:~/tmp/mmtest> grep -i remap *
rum:~/tmp/mmtest> 

I think you'll need to do something like

init():
	dsdt = get_free_pages(...)

chrdev mmap() op:
	remap_page_range(dsdt, ...)

If you are going to present data via /proc, you might as well simply
dump the raw data out to whoever is reading /proc/driver/acpi/dsdt...

-- 
Jeff Garzik              | My to-do list is a function
Building 1024            | which approaches infinity.
MandrakeSoft, Inc.       |
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
