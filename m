From: Christoph Rohland <cr@sap.com>
Subject: Re: [question] shm_nattch in sys_shmat?
Date: Mon, 03 Feb 2003 20:48:33 +0100
In-Reply-To: <3E3AFA3A.6050205@us.ibm.com> (Matthew Dobson's message of
 "Fri, 31 Jan 2003 14:35:38 -0800")
Message-ID: <ov4r7lf8mm.fsf@sap.com>
References: <3E3AFA3A.6050205@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: colpatch@us.ibm.com
Cc: linux-mm@kvack.org, William Lee Irwin III <wli@holomorphy.com>, "Martin J. Bligh" <mbligh@aracnet.com>
List-ID: <linux-mm.kvack.org>

Hi Matthew,

On Fri, 31 Jan 2003, Matthew Dobson wrote:
> 	sys_shmat, does in fact increment shm_nattch, but only to
> 	decrement it again a few lines later, as seen in this code
> 	snippet.  Can anyone please explain why this is?

sys_shmat temporarily increases shm_nattch to make sure it's never zero:

>  >>>	shp->shm_nattch++;

Make sure shm_nattch is greater than zero.

>  >	user_addr = (void*) do_mmap (file, addr, size, prot,

map the segment which increments shm_nattch in shm_mmap accounting for
the actual mapping

>  >>>	shp->shm_nattch--;

Correct it again.

Greetings
		Christoph


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
