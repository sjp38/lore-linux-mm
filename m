Subject: Re: VM Requirement Document - v0.0
References: <20010626155838.A23098@jmcmullan.resilience.com>
From: John Fremlin <vii@users.sourceforge.net>
Date: 28 Jun 2001 23:47:53 +0100
In-Reply-To: <20010626155838.A23098@jmcmullan.resilience.com> (Jason McMullan's message of "Tue, 26 Jun 2001 15:58:38 -0400")
Message-ID: <m24rt0gr1i.fsf@boreas.yi.org.>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jason McMullan <jmcmullan@linuxcare.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[...]

> 	immediate: RAM, on-chip cache, etc. 
> 	fast:	   Flash reads, ROMs, etc.
> 	medium:    Hard drives, CD-ROMs, 100Mb ethernet, etc.
> 	slow:	   Flash writes, floppy disks,  CD-WR burners
> 	packeted:  Reads/write should be in as large a packet as possible
> 
> Embedded Case

[...]

> Desktop Case

I'm not sure there's any point in separating the cases like this.  The
complex part of the VM is the caching part => to be a good cache you
must take into account the speed of accesses to the cached medium,
including warm up times for sleepy drives etc.

It would be really cool if the VM could do that, so e.g. in the ideal
world you could connect up a slow harddrive and have its contents
cached as swap on your fast harddrive(!) (not a new idea btw and
already implemented elsewhere). I.e. from the point of view of the VM a
computer is just a group of data storage units and it's allowed to use
up certain parts of each one to do stuff

[...]

-- 

	http://ape.n3.net
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
