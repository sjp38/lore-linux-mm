Date: Wed, 3 Oct 2007 10:51:15 +0000
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: VM/VFS bug with large amount of memory and file systems?
Message-ID: <20071003105115.GA6300@ucw.cz>
References: <C2A8AED2-363F-4131-863C-918465C1F4E1@cam.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <C2A8AED2-363F-4131-863C-918465C1F4E1@cam.ac.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Anton Altaparmakov <aia21@cam.ac.uk>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, marc.smith@esmail.mcc.edu
List-ID: <linux-mm.kvack.org>

On Sat 2007-09-15 08:27:23, Anton Altaparmakov wrote:
> Hi,
> 
> Mark Smith reported a OOM condition when he copies a 
> large (46GiB)  file from an NTFS partition (using the 
> stock kernel driver) to /dev/ null (or to a file on 
> ext3, same result).
> 
> The machine this runs on has an i386 kernel with 12GiB 
> RAM (yes this  is not a typo it is 12GiB!).

Yes, that's known broken. 32bit machines with to much memory just do
not work properly.

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
