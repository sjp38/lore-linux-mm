Subject: Re: Hangs in 2.5.41-mm1
From: Paul Larson <plars@linuxtestproject.org>
In-Reply-To: <3DA4A06A.B84D4C05@digeo.com>
References: <3DA48EEA.8100302C@digeo.com> <1034195372.30973.64.camel@plars>
	 <3DA4A06A.B84D4C05@digeo.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 10 Oct 2002 10:45:49 -0500
Message-Id: <1034264750.30975.83.camel@plars>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2002-10-09 at 16:32, Andrew Morton wrote:
> -mm2 will cure all ills ;)

If only we could be so lucky! :)

Linux-2.5.41-mm2
# echo 768 > /proc/sys/vm/nr_hugepages
# echo 1610612736 > /proc/sys/kernel/shmmax
# ./shmt01
./shmt01: IPC Shared Memory TestSuite program

        Get shared memory segment (67108864 bytes)

        Attach shared memory segment to process

        Index through shared memory segment ...

        Release shared memory

successful!
# ./shmt01 -s 1610612736./shmt01: IPC Shared Memory TestSuite program

        Get shared memory segment (1610612736 bytes)

        Attach shared memory segment to process

        Index through shared memory segment ...

        Release shared memory

successful!
#
*HANG*

I went back and tried to reproduce it.  I got through the first run of
shmt01, then got half the command typed of the second run through it and
it hang.  So if anything, it would appear that mm2 is easier to hang
than mm1.

-Paul Larson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
