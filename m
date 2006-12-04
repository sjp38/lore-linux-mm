Date: Mon, 4 Dec 2006 10:47:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch/rfc 0/2] vmemmap for s390
Message-Id: <20061204104714.bc800a03.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20061201140542.GA8788@osiris.boeblingen.de.ibm.com>
References: <20061201140542.GA8788@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux-mm@kvack.org, schwidefsky@de.ibm.com, cotte@de.ibm.com
List-ID: <linux-mm.kvack.org>

On Fri, 1 Dec 2006 15:05:42 +0100
Heiko Carstens <heiko.carstens@de.ibm.com> wrote:

> This is the s390 implementation (both 31 and 64 bit) of a virtual memmap.
> ia64 was used as a blueprint of course. I hope I incorporated everything
> I read lately on linux-mm wrt. vmemmap.
> So I post this as an RFC, since I most probably have forgotten something,
> or did something wrong. Comments highly appreciated.
> 
> This patchset is against linux-2.6.19-rc6-mm2.
> 
> Patch 1 is sort of unrelated to the vmemmap patch but still needed, so
> that the patch applies.
> Patch 2 is the vmemmap implementation.
> 

- Could you divide Patch 2 into a few pieces ?
  * setup, vmemmap pagetable creation, shared memory codes , etc...

- Do you need vmemmap for 32 bits ? (just a question)

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
