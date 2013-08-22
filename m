Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 7D7276B0033
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 11:11:28 -0400 (EDT)
Date: Thu, 22 Aug 2013 10:11:26 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCH 7/7] drivers: base: refactor add_memory_section() to
 add_memory_block()
Message-ID: <20130822151126.GA3748@medulla.variantweb.net>
References: <1377018783-26756-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1377018783-26756-7-git-send-email-sjenning@linux.vnet.ibm.com>
 <5215C9B3.4090608@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5215C9B3.4090608@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dave Hansen <dave@sr71.net>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Yinghai Lu <yinghai@kernel.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On Thu, Aug 22, 2013 at 05:20:03PM +0900, Yasuaki Ishimatsu wrote:
> (2013/08/21 2:13), Seth Jennings wrote:
> > -	for (i = 0; i < NR_MEM_SECTIONS; i++) {
> > -		if (!present_section_nr(i))
> > -			continue;
> > -		/* don't need to reuse memory_block if only one per block */
> > -		err = add_memory_section(__nr_to_section(i),
> > -				 (sections_per_block == 1) ? NULL : &mem);
> > +	for (i = 0; i < NR_MEM_SECTIONS; i += sections_per_block) {
> 
> Why do you remove present_setcion_nr() check?

The previous logic was that if any section was present in the memory
block that the memory block is created.  If you do the
present_setcion_nr() check here, if the first section isn't
present, it skips the whole memory block, even though there may have
been other present sections in that block, which isn't what we want.

Seth

> 
> > +		err = add_memory_block(i);
> >   		if (!ret)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
