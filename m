Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m67LNQc6029350
	for <linux-mm@kvack.org>; Mon, 7 Jul 2008 17:23:26 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m67LNGA0214606
	for <linux-mm@kvack.org>; Mon, 7 Jul 2008 17:23:16 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m67LNFeu025676
	for <linux-mm@kvack.org>; Mon, 7 Jul 2008 17:23:16 -0400
Message-ID: <48728942.6050007@austin.ibm.com>
Date: Mon, 07 Jul 2008 16:23:14 -0500
From: Joel Schopp <jschopp@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: [patch 0/6] Strong Access Ordering page attributes for POWER7
References: <20080618223254.966080905@linux.vnet.ibm.com>	 <1215128392.7960.7.camel@pasglop> <1215439540.16098.15.camel@norville.austin.ibm.com>
In-Reply-To: <1215439540.16098.15.camel@norville.austin.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Paul Mackerras <paulus@au1.ibm.com>, Linuxppc-dev@ozlabs.org
List-ID: <linux-mm.kvack.org>

>> We haven't defined a user-visible feature bit (and besides, we're really
>> getting short on these...). This is becoming a bit of concern btw (the
>> running out of bits). Maybe we should start defining an AT_HWCAP2 for
>> powerpc and get libc updated to pick it up ?
>>     
>
> Joel,
> Any thoughts?
Is it a required or optional feature of the 2.06 architecture spec?  If it's required you could just use that.  It doesn't solve the problem more generically if other archs decide to implement it though.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
