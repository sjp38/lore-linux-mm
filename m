Date: Thu, 1 Nov 2001 14:08:07 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Physical address of a user virtual address
Message-ID: <20011101140807.B2321@redhat.com>
References: <OF59D35C34.54785967-ON86256AF5.0002C7E7@hou.us.ray.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <OF59D35C34.54785967-ON86256AF5.0002C7E7@hou.us.ray.com>; from Mark_H_Johnson@Raytheon.com on Mon, Oct 29, 2001 at 06:42:51PM -0600
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark_H_Johnson@Raytheon.com
Cc: linux-mm@kvack.org, James_P_Cassidy@Raytheon.com
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Oct 29, 2001 at 06:42:51PM -0600, Mark_H_Johnson@Raytheon.com wrote:

> We can't seem to find any "easy" way (e.g., call a function) that converts
> an address in the virtual address space of an application to the physical
> address. The book "Linux Device Drivers" basically tells us to walk the
> page tables. From that, we think we must create a driver or kernel module
> to get access to the proper variables and functions. That looks like a lot
> of work for something that sounds simple.
> 
> Has someone already solved this done this and can point us to some code
> that implements this?

map_user_kiobuf() is designed to walk the page tables, find the
appropriate physical pages and pin them in memory.  

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
