Date: Fri, 7 Nov 2003 20:53:57 -0500 (EST)
From: "Raghu R. Arur" <rra2002@cs.columbia.edu>
Subject: Re: linux vm page sharing
In-Reply-To: <Pine.GSO.4.58.0311071728220.12831@lectura.CS.Arizona.EDU>
Message-ID: <Pine.LNX.4.44.0311072049540.571-100000@beijing.clic.cs.columbia.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Sharath Kodi Udupa <sku@CS.Arizona.EDU>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


  I think the idea you are proposing is already present in linux. If two 
executables are using the same library file, then there wont be two 
instances of the page of that library file..

 The address_space in the page maps to the the inode of the file that the 
page is mapped to (in case of a file mapped file) or it will be NULL for 
non-mapped pages. In 2.6 mm, the pages that hold the page table entries of 
a process use this mapping to map to the mm_struct of that process.

 HTH,
 Raghu

On Fri, 7 Nov 2003, Sharath Kodi Udupa wrote:

> hi,
> 
> i am trying to implement a system where different processes can share
> pages, this means that not only same executables, but different
> executables , but when the pages required are same.
> but i see in the linux page structure, it keeps a pointer to the
> address_space mapping, but now since if the second process also needs to
> share the page,this wont be the same mapping. so i am planning to add the
> page table entry to the second process, but to leave the
> struct address_space *mapping pointer to whatever it was earlier. I plan
> to do this since, i dont really understand how this is used and also have
> gone through the code to understand it. What significance does this hold?
> 
> any pointers is greatly appreciated
> 
> regards,
> 
> Sharath K Udupa
> Graduate Student,
> Dept. of Computer Science,
> University of Arizona.
> sku@cs.arizona.edu
> http://www.cs.arizona.edu/~sku
> 
> "Sometimes I think the surest sign that intelligent life exists
> elsewhere in the universe is that none of it has tried to contact us."
> --Calvin, The Indispensable Calvin and Hobbes
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
