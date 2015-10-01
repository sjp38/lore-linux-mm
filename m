Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id D7C996B0296
	for <linux-mm@kvack.org>; Thu,  1 Oct 2015 13:19:05 -0400 (EDT)
Received: by iofh134 with SMTP id h134so93473335iof.0
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 10:19:05 -0700 (PDT)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id n125si5692170ion.3.2015.10.01.10.19.03
        for <linux-mm@kvack.org>;
        Thu, 01 Oct 2015 10:19:03 -0700 (PDT)
Subject: Re: [PATCH 07/25] x86, pkeys: new page fault error code bit: PF_PK
References: <20150928191817.035A64E2@viggo.jf.intel.com>
 <20150928191820.BF4CBF05@viggo.jf.intel.com>
 <alpine.DEB.2.11.1510011351150.4500@nanos>
From: Dave Hansen <dave@sr71.net>
Message-ID: <560D6B06.6040505@sr71.net>
Date: Thu, 1 Oct 2015 10:19:02 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.11.1510011351150.4500@nanos>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: borntraeger@de.ibm.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@linux.intel.com

On 10/01/2015 04:54 AM, Thomas Gleixner wrote:
> On Mon, 28 Sep 2015, Dave Hansen wrote:
>> >  
>> >  /*
>> > @@ -916,7 +918,10 @@ static int spurious_fault_check(unsigned
>> >  
>> >  	if ((error_code & PF_INSTR) && !pte_exec(*pte))
>> >  		return 0;
>> > -
>> > +	/*
>> > +	 * Note: We do not do lazy flushing on protection key
>> > +	 * changes, so no spurious fault will ever set PF_PK.
>> > +	 */
> It might be a bit more clear to have:
> 
>    	/* Comment .... */
>   	if ((error_code & PF_PK))
>   		return 1;
> 
>   	return 1;
> 
> That way the comment is associated to obviously redundant code, but
> it's easier to read, especially if we add some new PF_ thingy after
> that.

Agreed, that's a nicer way to do it.  I'll fix it up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
