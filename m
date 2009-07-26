Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id AF2FB6B009F
	for <linux-mm@kvack.org>; Sun, 26 Jul 2009 10:56:13 -0400 (EDT)
Message-ID: <4A6C6F96.2050207@redhat.com>
Date: Sun, 26 Jul 2009 18:00:38 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/4] (Take 2): transcendent memory ("tmem") for Linux
References: <a09e4489-a755-46e7-a569-a0751e0fc39f@default> <4A5A1A51.2080301@redhat.com> <4A5A3AC1.5080800@codemonkey.ws> <20090713201745.GA3783@think> <4A5B9B55.6000404@codemonkey.ws> <20090713210112.GC3783@think> <4A5BA451.5070604@codemonkey.ws>
In-Reply-To: <4A5BA451.5070604@codemonkey.ws>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Anthony Liguori <anthony@codemonkey.ws>
Cc: Chris Mason <chris.mason@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, npiggin@suse.de, akpm@osdl.org, jeremy@goop.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, kurt.hackel@oracle.com, Rusty Russell <rusty@rustcorp.com.au>, dave.mccracken@oracle.com, Marcelo Tosatti <mtosatti@redhat.com>, sunil.mushran@oracle.com, Schwidefsky <schwidefsky@de.ibm.com>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On 07/14/2009 12:17 AM, Anthony Liguori wrote:
> Chris Mason wrote:
>> On Mon, Jul 13, 2009 at 03:38:45PM -0500, Anthony Liguori wrote:
>>   I'll definitely grant that caching with writethough adds more caching,
>> but it does need trim support before it is similar to tmem.
>
> I think trim is somewhat orthogonal but even if you do need it, the 
> nice thing about implementing ATA trim support verses a 
> paravirtualization is that it works with a wide variety of guests.
>
> From the perspective of the VMM, it seems like a good thing.

trim is also lovely in that images will no longer grow monotonously even 
though guest disk usage is constant or is even reduced.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
