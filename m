Subject: Re: [RFC] sys_punchhole()
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <1131664994.25354.36.camel@localhost.localdomain>
References: <1131664994.25354.36.camel@localhost.localdomain>
Content-Type: text/plain
Date: Fri, 11 Nov 2005 06:18:33 +0100
Message-Id: <1131686314.2833.0.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: akpm@osdl.org, andrea@suse.de, hugh@veritas.com, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2005-11-10 at 15:23 -0800, Badari Pulavarty wrote:
> 
> We discussed this in madvise(REMOVE) thread - to add support 
> for sys_punchhole(fd, offset, len) to complete the functionality
> (in the future).

in the past always this was said to be "really hard" in linux locking
wise, esp. the locking with respect to truncate...

did you find a solution to this problem ?
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
