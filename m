Date: Tue, 26 Feb 2002 10:21:49 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: thanks
Message-ID: <20020226102149.D2023@redhat.com>
References: <F193xCZPs6AvbEPDjQh0000c5bd@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <F193xCZPs6AvbEPDjQh0000c5bd@hotmail.com>; from shen_haiying@hotmail.com on Tue, Feb 26, 2002 at 10:18:27AM +0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Shen Haiying <shen_haiying@hotmail.com>
Cc: linux-mm@kvack.org, raz@mailhost.directlink.net, owner-linux-mm@kvack.org, kanoj@google.engr.sgi.com
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Feb 26, 2002 at 10:18:27AM +0800, Shen Haiying wrote:
 
> I am a student of Wayne State university. I take the course of "advanced 
> operating system" this semester. In order to finish my assignment, I need 
> to know the source code of "shmget, shmat, shmdt, shmctl" in linux. I 
> searched them on the internet in this whole afternoon and night, but I 
> could not find it. Now, I am very depressed. I think this is my last hope 
> to ask you for help. Could you please send me the Linux OS source code 
> about the "shmget, shmat, shmdt, shmctl"? 

Visit www.kernel.org.  Search for linux-2.4.18.tar.gz.  Download it.
Unpack it.  See "linux/ipc/shm.c".  If it takes you more than half a
day, you probably need to find an easier course. :-)

There is also an online Linux kernel source cross-reference available
at http://lxr.linux.no/ to let you see individual source files without
downloading the entire source code.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
