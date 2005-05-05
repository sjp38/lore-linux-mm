Message-ID: <427A59BC.1020208@shadowen.org>
Date: Thu, 05 May 2005 18:37:00 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [3/3] sparsemem memory model for ppc64
References: <E1DTQWH-0002We-I9@pinky.shadowen.org> <20050505023132.GB20283@austin.ibm.com>
In-Reply-To: <20050505023132.GB20283@austin.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Olof Johansson <olof@lixom.net>
Cc: linuxppc64-dev@ozlabs.org, paulus@samba.org, anton@samba.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haveblue@us.ibm.com, kravetz@us.ibm.com
List-ID: <linux-mm.kvack.org>

Olof Johansson wrote:
> Hi,
> 
> Just two formatting nitpicks below.

Thanks, this would be better served by rewriting the first comment and
removing the second all together.

/* Add all physical memory to the bootmem map, mark each area
 * present.  The first block has already been marked present above.
 */

I note that the diff in question has sneaked into the wrong patch, that
segement represents memory_present.  So I'll rediff them with it there.
 No overall change to the code.

-apw
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
