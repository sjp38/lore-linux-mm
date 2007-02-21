Message-ID: <45DC9466.5020508@redhat.com>
Date: Wed, 21 Feb 2007 13:50:14 -0500
From: Peter Staubach <staubach@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] update ctime and mtime for mmaped write
References: <E1HJvdA-0003Nj-00@dorka.pomaz.szeredi.hu>	 <1172081562.9108.1.camel@heimdal.trondhjem.org>	 <E1HJwCl-0003V6-00@dorka.pomaz.szeredi.hu> <1172083004.9108.6.camel@heimdal.trondhjem.org>
In-Reply-To: <1172083004.9108.6.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Miklos Szeredi <miklos@szeredi.hu>, akpm@linux-foundation.org, hugh@veritas.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Trond Myklebust wrote:
> On Wed, 2007-02-21 at 19:28 +0100, Miklos Szeredi wrote:
>   
>>>> This flag is checked in msync() and __fput(), and if set, the file
>>>> times are updated and the flag is cleared
>>>>         
>>> Why not also check inside vfs_getattr?
>>>       
>> This is the minimum, that the standard asks for.
>>
>> Note, your porposal would touch the times in vfs_getattr(), which
>> means, that the modification times would depend on the time of the
>> last stat() call, which is not really right, though it would still be
>> conforming.
>>
>> It is much saner, if the modification time is always the time of the
>> last write() or msync().
>>     
>
> I disagree. The above doesn't allow a program like 'make' to discover
> whether or not the file has changed by simply calling stat(). Instead,
> you're forcing a call to msync()+stat().

Right, but that's what the specification specifies.  The file times
for mmap'd files are not maintained as tightly as they are for files
which are being modified via write(2).

Rightly or wrongly.

       ps

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
