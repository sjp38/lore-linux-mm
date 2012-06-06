Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 5CAEB6B0088
	for <linux-mm@kvack.org>; Wed,  6 Jun 2012 12:03:10 -0400 (EDT)
Date: Wed, 06 Jun 2012 09:03:08 -0700 (PDT)
Message-Id: <20120606.090308.608629832776499558.davem@davemloft.net>
Subject: Re: [PATCH] powerpc: Fix assmption of end_of_DRAM() returns end
 address
From: David Miller <davem@davemloft.net>
In-Reply-To: <1338960617.7150.163.camel@pasglop>
References: <20120605.152058.828742127223799137.davem@davemloft.net>
	<6A3DF150A5B70D4F9B66A25E3F7C888D03D68F08@039-SN2MPN1-022.039d.mgd.msft.net>
	<1338960617.7150.163.camel@pasglop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org
Cc: R65777@freescale.com, aarcange@redhat.com, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, galak@kernel.crashing.org, linux-mm@kvack.org

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 06 Jun 2012 15:30:17 +1000

> On Wed, 2012-06-06 at 00:46 +0000, Bhushan Bharat-R65777 wrote:
> 
>> > >> memblock_end_of_DRAM() returns end_address + 1, not end address.
>> > >> While some code assumes that it returns end address.
>> > >
>> > > Shouldn't we instead fix it the other way around ? IE, make
>> > > memblock_end_of_DRAM() does what the name implies, which is to
>> return
>> > > the last byte of DRAM, and fix the -other- callers not to make bad
>> > > assumptions ?
>> > 
>> > That was my impression too when I saw this patch.
>> 
>> Initially I also intended to do so. I initiated a email on linux-mm@
>> subject "memblock_end_of_DRAM()  return end address + 1" and the only
>> response I received from Andrea was:
>> 
>> "
>> It's normal that "end" means "first byte offset out of the range". End
>> = not ok.
>> end = start+size.
>> This is true for vm_end too. So it's better to keep it that way.
>> My suggestion is to just fix point 1 below and audit the rest :)
>> "
> 
> Oh well, I don't care enough to fight this battle in my current state so
> unless Dave has more stamina than I have today, I'm ok with the patch.

I'm definitely without the samina to fight something like this right now :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
