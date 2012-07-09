Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 74DD86B006C
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 09:59:28 -0400 (EDT)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 9 Jul 2012 07:59:27 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id A41033E40066
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 13:58:44 +0000 (WET)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q69DwSIW226180
	for <linux-mm@kvack.org>; Mon, 9 Jul 2012 07:58:31 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q69DwQdK029552
	for <linux-mm@kvack.org>; Mon, 9 Jul 2012 07:58:27 -0600
Message-ID: <4FFAE37F.70403@linux.vnet.ibm.com>
Date: Mon, 09 Jul 2012 08:58:23 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] zsmalloc improvements
References: <1341263752-10210-1-git-send-email-sjenning@linux.vnet.ibm.com> <20120704204325.GB2924@localhost.localdomain> <4FF6FF1F.5090701@linux.vnet.ibm.com>
In-Reply-To: <4FF6FF1F.5090701@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad@darnok.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On 07/06/2012 10:07 AM, Seth Jennings wrote:
> On 07/04/2012 03:43 PM, Konrad Rzeszutek Wilk wrote:
>> On Mon, Jul 02, 2012 at 04:15:48PM -0500, Seth Jennings wrote:
>>> This exposed an interesting and unexpected result: in all
>>> cases that I tried, copying the objects that span pages instead
>>> of using the page table to map them, was _always_ faster.  I could
>>> not find a case in which the page table mapping method was faster.
>>
>> Which architecture was this under? It sounds x86-ish? Is this on
>> Westmere and more modern machines? What about Core2 architecture?
>>
>> Oh how did it work on AMD Phenom boxes?
> 
> I don't have a Phenom box but I have an Athlon X2 I can try out.
> I'll get this information next Monday.

Actually, I'm running some production stuff on that box, so
I rather not put testing stuff on it.  Is there any
particular reason that you wanted this information? Do you
have a reason to believe that mapping will be faster than
copy for AMD procs?

(To everyone) I'd like to get this acked before the 3.6
merge window if there are no concerns/objections.

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
