Received: from d23rh902.au.ibm.com (d23rh902.au.ibm.com [9.185.167.101])
	by ausmtp02.au.ibm.com (8.12.1/8.12.1) with ESMTP id g77H13K4122054
	for <linux-mm@kvack.org>; Thu, 8 Aug 2002 03:01:03 +1000
Received: from d23m0067.in.ibm.com (d23m0067.in.ibm.com [9.184.199.180])
	by d23rh902.au.ibm.com (8.12.3/NCO/VER6.3) with ESMTP id g77H3A35055812
	for <linux-mm@kvack.org>; Thu, 8 Aug 2002 03:03:11 +1000
Subject: oom_killer - Does not perform when stress-tested (system hangs)
Message-ID: <OFDE4A1CCD.14106609-ON65256C0E.0057D9B9@in.ibm.com>
From: "Srikrishnan Sundararajan" <srikrishnan@in.ibm.com>
Date: Wed, 7 Aug 2002 22:31:21 +0530
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,
I'm trying to run multiple instances of the following program which keeps
on allocating memory , assigns value if malloc was not NULL  and does not
free.
#include <stdlib.h>
int main()
{
   int *p,i;
   while (1)  {
      p = (int *) malloc(1000000 * sizeof(int));
      if(p!=NULL)
          for(i=0;i<1000000;i++)
             p[i]=i;
      sleep(1);
   }
}


When I run say about 5 instances, oom_killer kills one instance of my
program when SwapFree is 0K, goes on to kill each of the other instances in
turn. The machine is slow in response when my program was running but
perfectly usable after that.
When I run 25 or 40 instances, the system hangs. No response. After waiting
for more than 1.5 hours I did a manual reboot (hard-reset). I looked for
/var/log/messages for "Out of Memory: Killed process...", I could find
about 15 entries for the killing of my program's instances, none for others
and there were no entries for more than an hour till I hard-reset the
machine.
I used a PC with Linux -2.4.7-10 (RH 7.2). RAM:128 MB, Swap: 256 MB. I run
as an user and not as root.

Is this expected behavior? Is it the responsibility of the user not to
"fill" the memory? Could oom_killer not take care of such a stress-test?
Should any thing warn the user when swap-space is full?


Srikrishnan


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
