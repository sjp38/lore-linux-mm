From: Mark_H_Johnson@Raytheon.com
Subject: Re: Running out of memory in 1 easy step
Message-ID: <OF197FE829.51802B4B-ON8625695B.0048CCDB@hou.us.ray.com>
Date: Fri, 15 Sep 2000 08:22:48 -0500
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: hahn@coffee.psychology.mcmaster.ca
Cc: linux-mm@kvack.org, Wichert Akkerman <wichert@cistron.nl>
List-ID: <linux-mm.kvack.org>

I hate to ask, but where is this behavior described?  I can't find any hint
of this behavior in the man page. I'm concerned because we would not have
taken the "guard pages" into account when sizing our application's memory
usage. We have a real time application where we will also lock the pages
into memory - running out of physical memory in this case is "very bad".
Thanks.

--Mark H Johnson
  <mailto:Mark_H_Johnson@raytheon.com>


                                                                                                                                 
                    Mark Hahn                                                                                                    
                    <hahn@coffee.psychology.mc        To:     Wichert Akkerman <wichert@cistron.nl>                              
                    master.ca>                        cc:     linux-mm@kvack.org, (bcc: Mark H Johnson/RTS/Raytheon/US)          
                                                      Subject:     Re: Running out of memory in 1 easy step                      
                    09/14/00 06:03 PM                                                                                            
                                                                                                                                 
                                                                                                                                 



> Not likely, there were still a couple hundreds of megabytes free and
> the process had allocated about 1.5Gb of data.

mmaping 1 to 4096 bytes consumes 8K from your address space:
one for the mmaped page, and one (virtual) guard page (unless
you use MAP_FIXED, of course.)  4G / 8K is approximately the 458878
you reported.  actually, since maps begin at 1G, I would have
expected you to run out sooner...

regards, mark hahn.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
