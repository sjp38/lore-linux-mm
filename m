Date: Thu, 10 Nov 2005 15:32:54 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC] sys_punchhole()
Message-Id: <20051110153254.5dde61c5.akpm@osdl.org>
In-Reply-To: <1131664994.25354.36.camel@localhost.localdomain>
References: <1131664994.25354.36.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: andrea@suse.de, hugh@veritas.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Badari Pulavarty <pbadari@us.ibm.com> wrote:
>
> We discussed this in madvise(REMOVE) thread - to add support 
> for sys_punchhole(fd, offset, len) to complete the functionality
> (in the future).
> 
> http://marc.theaimsgroup.com/?l=linux-mm&m=113036713810002&w=2
> 
> What I am wondering is, should I invest time now to do it ?

I haven't even heard anyone mention a need for this in the past 1-2 years.

> Or wait till need arises ? 

A long wait, I suspect..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
