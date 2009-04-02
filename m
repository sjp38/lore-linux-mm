Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 31DD36B003D
	for <linux-mm@kvack.org>; Thu,  2 Apr 2009 12:18:27 -0400 (EDT)
Message-ID: <49D4E55F.8010406@goop.org>
Date: Thu, 02 Apr 2009 09:18:39 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [patch 0/6] Guest page hinting version 7.
References: <20090327150905.819861420@de.ibm.com>	<200903281705.29798.rusty@rustcorp.com.au>	<20090329162336.7c0700e9@skybase>	<200904022232.02185.nickpiggin@yahoo.com.au> <20090402175249.3c4a6d59@skybase>
In-Reply-To: <20090402175249.3c4a6d59@skybase>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, akpm@osdl.org, frankeh@watson.ibm.com, virtualization@lists.osdl.org, riel@redhat.com, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Martin Schwidefsky wrote:
>> I still think this needs much more justification.
>>     
>  
> Ok, I can understand that. We probably need a KVM based version to show
> that benefits exist on non-s390 hardware as well.
>   

BTW, there was a presentation at the most recent Xen summit which makes 
use of CMM ("Satori: Enlightened Page Sharing", 
http://www.xen.org/files/xensummit_oracle09/Satori.pdf).

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
