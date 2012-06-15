Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 224216B006E
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 19:28:15 -0400 (EDT)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Fri, 15 Jun 2012 17:28:14 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 3124019D804A
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 23:27:19 +0000 (WET)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5FNQnhI183966
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 17:27:05 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5FNQXoM014698
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 17:26:34 -0600
Message-ID: <4FDBC4A7.8050507@linux.vnet.ibm.com>
Date: Fri, 15 Jun 2012 18:26:31 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 3/3] x86: Support local_flush_tlb_kernel_range
References: <1337133919-4182-1-git-send-email-minchan@kernel.org> <1337133919-4182-3-git-send-email-minchan@kernel.org> <4FB4B29C.4010908@kernel.org> <1337266310.4281.30.camel@twins> <4FDB5107.3000308@linux.vnet.ibm.com> <7e925563-082b-468f-a7d8-829e819eeac0@default> <4FDB66B7.2010803@vflare.org> <10ea9d19-bd24-400c-8131-49f0b4e9e5ae@default> <4FDB8808.9010508@linux.vnet.ibm.com> <9c6c8ae0-0212-402d-a906-0d0c61e5e058@default> <4FDB92CF.1070603@vflare.org> <4ffbc3e8-900b-4669-b6ab-e8c066f28c63@default> <4FDBA7CC.6060407@vflare.org>
In-Reply-To: <4FDBA7CC.6060407@vflare.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Nitin Gupta <ngupta@vflare.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Tejun Heo <tj@kernel.org>, David Howells <dhowells@redhat.com>, x86@kernel.org, Nick Piggin <npiggin@gmail.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>

On 06/15/2012 04:23 PM, Nitin Gupta wrote:

> On 06/15/2012 01:13 PM, Dan Magenheimer wrote:

>>

>> OK, it's your code and I'm just making a suggestion. I will shut up now ;-)
>>
> 
> I'm always glad to hear your opinions and was just trying to discuss the
> points you raised. I apologize if I sounded rude.

Same here. It's always good to go back and rethink your assumptions.
Thanks Dan!

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
