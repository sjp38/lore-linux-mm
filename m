Message-ID: <3BDEEEAE.3000505@interactivesi.com>
Date: Tue, 30 Oct 2001 12:17:18 -0600
From: Timur Tabi <ttabi@interactivesi.com>
MIME-Version: 1.0
Subject: Re: Physical address of a user virtual address
References: <OF59D35C34.54785967-ON86256AF5.0002C7E7@hou.us.ray.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark_H_Johnson@Raytheon.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mark_H_Johnson@Raytheon.com wrote:

> We can't seem to find any "easy" way (e.g., call a function) that converts
> an address in the virtual address space of an application to the physical
> address. The book "Linux Device Drivers" basically tells us to walk the
> page tables. From that, we think we must create a driver or kernel module
> to get access to the proper variables and functions. That looks like a lot
> of work for something that sounds simple.


User apps are not supposed to be concerned with physical memory, so it doesn't 
surprise me at all that you need to make a driver.  Fortunately, writing a 
driver isn't that difficult.  I'd help you out, if I didn't already have a job 
doing exactly what you're looking for!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
