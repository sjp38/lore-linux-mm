Date: Mon, 10 Jun 2002 09:57:50 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: slab cache
Message-ID: <20020610095750.B2571@redhat.com>
References: <3D036BBE.4030603@shaolinmicro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3D036BBE.4030603@shaolinmicro.com>; from davidchow@shaolinmicro.com on Sun, Jun 09, 2002 at 10:52:46PM +0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chow <davidchow@shaolinmicro.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Sun, Jun 09, 2002 at 10:52:46PM +0800, David Chow wrote:
 
> I am trying to improve the speed of my fs code. I have a fixed sized 
> buffer for my fs, I currently use kmalloc for allocation of buffers 
> greater than 4k, use get_free_page for 4k buffers and vmalloc for large 
> buffers.

Allocations larger than pagesize always put a higher stress on the VM
and reduce performance.  Your best bet for top performance will be
simply to perform no allocations larger than pagesize.  You can use a
slab cache for those allocations if you want, and that may have some
advantages depending on the locality of allocations in your code.

Using 4k buffers does not limit your ability to use larger data
structures --- you can still chain 4k buffers together by creating an
array of struct page* pointers via which you can access the data.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
