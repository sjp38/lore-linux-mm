Date: Thu, 23 Apr 1998 11:12:12 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: Fixing private mappings
In-Reply-To: <m1ra2pnn3c.fsf@flinx.npwt.net>
Message-ID: <Pine.LNX.3.95.980423105842.15346A-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@npwt.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 23 Apr 1998, Eric W. Biederman wrote:

> Please excuse me for thinking out loud but private mappings seems to be
> a hard problem that has not been correctly implemented in the linux
> kernel.
> 
> Definition of Private Mappings:
>  A private mapping is a copy-on-write mapping of a file.  
> 
>  That is if the file is written to after the mapping is established,
>  the contents of the mapping will always remain what the contents of
>  the file was at the time of the private mapping.

No, this is not the case.  Examine the behaviour of other unicies out
there that implement mmap.  The following is quoted from the man page for
mmap on Solaris:

     MAP_SHARED and MAP_PRIVATE describe the disposition of write
     references  to  the  memory object.  If MAP_SHARED is speci-
     fied, write references will change the  memory  object.   If
     MAP_PRIVATE  is  specified, the initial write reference will
     create a private copy of the memory object page and redirect
     the  mapping  to  the copy. Either MAP_SHARED or MAP_PRIVATE
     must be specified,  but  not  both.   The  mapping  type  is
     retained across a fork(2).

Note: 'the initial write reference will create a private copy' -- not
the act of reading or mapping.

>  Further if another private mapping is established after one
>  private mapping has been established it should have the file contents
>  of the file at the time the mapping is established.  Not at the time
>  any previous private mapping was established.

Linux does behave this way currently.

...
> A slightly more generic solution would be to introduce a new ``inode''
> that new it was a copy of the old inode but at a different offset.  If
> these new ``inodes'' would then have a linked list of their own, that
> could be followed for update purposes.  
...

This would be the appropriate thing to do if you'd like see such exotic
behaviour ;-)

		-ben
