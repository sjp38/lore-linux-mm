Received: from bucky.physics.ncsu.edu (bucky.physics.ncsu.edu [152.1.119.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA20378
	for <linux-mm@kvack.org>; Mon, 31 May 1999 14:57:06 -0400
Received: (from briggs@localhost) by bucky.physics.ncsu.edu (AIX4.2/UCB 8.7/8.7) id PAA13206 for linux-mm@kvack.org; Mon, 31 May 1999 15:11:08 -0400 (EDT)
Date: Mon, 31 May 1999 15:11:08 -0400 (EDT)
From: Emil Briggs <briggs@bucky.physics.ncsu.edu>
Message-Id: <199905311911.PAA13206@bucky.physics.ncsu.edu>
Subject: Application load times
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Are there any vm tuning parameters that can improve initial application
load times on a freshly booted system? I'm asking since I found the
following load times with Netscape Communicator and StarOffice.


Communicator takes 14 seconds to load on a freshly booted system

On the other hand it takes 4 seconds to load using a program of this sort

  fd = open("/opt/netscape/netscape", O_RDONLY);
  read(fd, buffer, 13858288);    
  execv("/opt/netscape/netscape", argv);

With StarOffice the load time drops from 40 seconds to 15 seconds.


The reason this came up is because I installed Linux on a friends
computer who usually boots it a couple of times a day to check email,
webbrowse or run StarOffice -- they immediately asked me why it
was so slow. Since I know how they usually use their computer it was
easy enough to remedy this with the little bit of code above. Anyway
does anyone know if there a more general way of improving initial load
times with some tuning parameters to the vm system?

Emil

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
