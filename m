Date: Sat, 5 Jun 1999 02:10:29 -0400 (EDT)
From: Vladimir Dergachev <vdergach@sas.upenn.edu>
Subject: Re: Application load times
In-Reply-To: <199905311911.PAA13206@bucky.physics.ncsu.edu>
Message-ID: <Pine.GSO.4.10.9906050207170.10625-100000@mail2.sas.upenn.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Emil Briggs <briggs@bucky.physics.ncsu.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Take a look at the preload package I wrote some time ago

  http://www.math.upenn.edu/~vdergach/Linux

The long load times are due the fact that the pages are loaded on demand.
Since programs are not likely to just execute linearly there is a lot
of seeking on the disk which slows things down. Note this is still faster
than loading the whole executables. 

Preload reorders loading of files so that the exact parts of the
executable are loaded in the correct order.

I am working on using dentries now to get the information about memory
allocation faster..

                         Vladimir Dergachev

On Mon, 31 May 1999, Emil Briggs wrote:

> Are there any vm tuning parameters that can improve initial application
> load times on a freshly booted system? I'm asking since I found the
> following load times with Netscape Communicator and StarOffice.
> 
> 
> Communicator takes 14 seconds to load on a freshly booted system
> 
> On the other hand it takes 4 seconds to load using a program of this sort
> 
>   fd = open("/opt/netscape/netscape", O_RDONLY);
>   read(fd, buffer, 13858288);    
>   execv("/opt/netscape/netscape", argv);
> 
> With StarOffice the load time drops from 40 seconds to 15 seconds.
> 
> 
> The reason this came up is because I installed Linux on a friends
> computer who usually boots it a couple of times a day to check email,
> webbrowse or run StarOffice -- they immediately asked me why it
> was so slow. Since I know how they usually use their computer it was
> easy enough to remedy this with the little bit of code above. Anyway
> does anyone know if there a more general way of improving initial load
> times with some tuning parameters to the vm system?
> 
> Emil
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
> in the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://humbolt.geo.uu.nl/Linux-MM/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
