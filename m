Received: from dipole.es.usyd.edu.au (dipole.es.usyd.edu.au [129.78.124.227])
	by amethyst.es.usyd.edu.au (8.9.3+Sun/8.9.3) with ESMTP id OAA07512
	for <linux-mm@kvack.org>; Sun, 14 Apr 2002 14:28:09 +1000 (EST)
Date: Sun, 14 Apr 2002 14:29:46 +1000 (EST)
From: ivan <ivan@es.usyd.edu.au>
Subject: Memory leak.
Message-ID: <Pine.LNX.4.33.0204141413150.18941-100000@dipole.es.usyd.edu.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi guy,

I am running 7.2RedHat kernel 2.4.9-31 from respect on Dell 4400 PowerEdge 
Server. Dual CPU 990MHz.

The machine was a lemon from the start. We paid for it 16000$, to find out 
that one controller and two SCSI disk were broken out of the box. 

Then it kept crushing a couple time a months with clear logs. Dell 
replaced mum and both CPUs. Still going down. Refused to replace RAM 
( 4Gb) Asked me to test memory buy swapping chips around despite all my 
explanations that this is a production server. I even wrote a little add 
for Dell. Buy DELL and you in Hell  

10 Days ago I installed DNS and DHCP servers from RedHat and noticed that 
"top" shows that the amount of consumed memory is slowly and constantly 
growing. Machine become unstable and a few users complained that their 
files disappeared. ( we have good backup ). I re-booted 4 days ago and now 
it looks it is doing it again.

Could you please advice how can I detect memory leaks.

Any help will be appreciated.

Thank you in advance,
Ivan.




-- 
================================================================================

Ivan Teliatnikov,
F05 David Edgeworth Building,
Department of Geology and Geophysics,
School of Geosciences,
University of Sydney, 2006
Australia

e-mail: ivan@es.usyd.edu.au
ph:  061-2-9351-2031 (w)
fax: 061-2-9351-0184 (w)

===============================================================================

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
