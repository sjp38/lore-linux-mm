From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199908052150.OAA15398@google.engr.sgi.com>
Subject: Re: SHM, Issue attaching Oracle >500MB shared mem
Date: Thu, 5 Aug 1999 14:50:55 -0700 (PDT)
In-Reply-To: <199908051636781.SM00258@mailhost.directlink.net> from "Javan Dempsey" at Aug 5, 99 04:36:20 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: raz@mailhost.directlink.net
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> Hello,
> 	We're currently running a number of Linux based ia32 Oracle 8.0.5 DB Servers, and we seem to be running into a problem with attaching to > 500MB shared mem. I've increased SHMMAX and tweaked various other things in an attempt to fix the problem. Nothing seems to work, no matter what SHMMAX is set to, or anything else. SVRMGRL gives this error when trying to startup -
> 
> SVRMGR> startup open
> ORA-27123: unable to attach to shared memory segment
> Linux Error: 22: Invalid argument
> SVRMGR>

The best thing to do is probably put debug printks in sys_shmat() in
ipc/shm.c and identify what is causing the problem. 

> 
>  which seems to be an a shmat() error. Oracle is dumbfounded with the problem, and I'm not very familliar with the mm part of the kernel. The machine I am speaking of is a Quad Proc Dell PowerEdge 6350, with 4GB of physical mem, and 4GB of swap. Running a few of Kanoj's patches, along with his latest BIGMEM patch, although I've also tried stock kernels, and some of the -AC kernels. Actually, with 2.2.10-ac11, and the quick hack to support 2GB of mem, I couldnt use much more than 150MB of shared mem. The current configuration has gotten me the furthest, but still no dice. I've also tried this on various machines of different configs, i.e. some dual proc's (which shouldnt matter anyway I suppose), some with 1 or 2GB mem, and such. Anyone have any suggestions?

Other than the 4Gb physmem patch, which other of my patches are
you using?

As I said in private mail also browse

	http://reality.sgi.com/kanoj_engr/tuning.html

Feel free to get in touch with me by private mail ... I am quite interested
in being able to start off Oracle with some of my patches installed.

Kanoj
> 
> 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
