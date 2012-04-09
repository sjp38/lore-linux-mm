Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 33FDF6B007E
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 18:06:31 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 9 Apr 2012 16:06:30 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 392903E40048
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 16:06:28 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q39M6Fm1144530
	for <linux-mm@kvack.org>; Mon, 9 Apr 2012 16:06:18 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q39M6FmW013752
	for <linux-mm@kvack.org>; Mon, 9 Apr 2012 16:06:15 -0600
Message-ID: <4F835D53.3090201@linux.vnet.ibm.com>
Date: Mon, 09 Apr 2012 17:06:11 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] staging: zsmalloc: fix memory leak
References: <1333376036-9841-1-git-send-email-sjenning@linux.vnet.ibm.com> <d858d87f-6e07-4303-a9b3-e41ff93c8080@default> <4F7C7626.40506@linux.vnet.ibm.com> <4F83454A.3050007@linux.vnet.ibm.com> <20120409214316.GB535@kroah.com>
In-Reply-To: <20120409214316.GB535@kroah.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 04/09/2012 04:43 PM, Greg Kroah-Hartman wrote:
> A: No.
> Q: Should I include quotations after my reply?
> 
> http://daringfireball.net/2007/07/on_top

Noted. I only included what I did to keep the Ack chain in the
message, which I guess was unnecessary.

> On Mon, Apr 09, 2012 at 03:23:38PM -0500, Seth Jennings wrote:
>> Hey Greg,
>>
>> Haven't heard back from you on this patch and it needs to
>> get into the 3.4 -rc releases ASAP.  It fixes a substantial
>> memory leak when frontswap/zcache are enabled.
>>
>> Let me know if you need me to repost.
>>
>> The patch was sent on 4/2.
> 
> 5 meager days ago, with a major holliday in the middle, not to mention a
> conference as well.  That's bold.

Sorry about that.  Forgot about the summit and the holiday :-/

The date was not to convey "It's been a whole week! Why the delay?",
but to help you find the original patch in your stack of emails.

> It is not lost, is in my queue, and will get to Linus before 3.4-final
> comes out, don't worry.

I'll be more patient (and take into account summits/holiday) for replies.

Thanks Greg!

--
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
