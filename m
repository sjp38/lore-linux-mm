Message-ID: <39A4F3A3.3030102@SANgate.com>
Date: Thu, 24 Aug 2000 13:06:27 +0300
From: BenHanokh Gabriel <gabriel@SANgate.com>
MIME-Version: 1.0
Subject: purging file cache
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux-MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

hi

i'm trying to find a way to purge file caching in a consistent way.
i found 2 relevant function
invalidate_inode_pages()
truncate_inode_pages()

does truncate_inode_pages() remove the page_cache only or that it 
actually truncate the on-disk file?

can cache purging be done with a better granularity than the whole page, 
some thing like purge_inode_cache( mapping, start, length ) ?


i don't realy understand the new VM model in linux 2.4 and what level of 
consistancy exists between the page-cache and the file-buffers so i got 
a few more questions:

can i invalidate cache for mmaped file? ( the reason i'm asking this is 
that there is at least one os which doesn;t allow to purge cache from a 
mmaped file )

can i invalidate mmaped section of a file which some process own a 
READ-lock on it( so the next access to that section will cause 
page-fault) or that this will break the mmap semantic ?

are files marked for mandatory locking protected from mmap access, or 
that the file locks are checked only on the FS system_calls( read, 
write...) ?

hope that at least some of those many questions will be answers

please CC me for any answer

-- 
regards
Benhanokh Gabriel

-----------------------------------------------------------------------------
"If you think C++ is not overly complicated, just what is a
protected abstract virtual base class with a pure virtual private 
destructor,
and when was the last time you needed one?"
-- Tom Cargil, C++ Journal, Fall 1990. --

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
