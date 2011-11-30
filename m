Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 4487D6B004D
	for <linux-mm@kvack.org>; Wed, 30 Nov 2011 08:04:20 -0500 (EST)
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ehrhardt@linux.vnet.ibm.com>;
	Wed, 30 Nov 2011 13:04:16 -0000
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1507.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAUD4CGx2629818
	for <linux-mm@kvack.org>; Wed, 30 Nov 2011 13:04:14 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost.localdomain [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAUD4BCX008238
	for <linux-mm@kvack.org>; Wed, 30 Nov 2011 06:04:12 -0700
Message-ID: <4ED629CB.401@linux.vnet.ibm.com>
Date: Wed, 30 Nov 2011 14:04:11 +0100
From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/8] readahead: make default readahead size a kernel parameter
References: <20111121091819.394895091@intel.com> <20111121093846.251104145@intel.com> <20111121100137.GC5084@infradead.org> <20111121113540.GB8895@localhost> <20111124222822.GG29519@quack.suse.cz> <20111125003633.GP2386@dastard> <20111128023922.GA2141@localhost>
In-Reply-To: <20111128023922.GA2141@localhost>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Ankit Jain <radical@gmail.com>, Rik van Riel <riel@redhat.com>, Nikanth Karthikesan <knikanth@suse.de>, LKML <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>



On 11/28/2011 03:39 AM, Wu Fengguang wrote:
> On Fri, Nov 25, 2011 at 08:36:33AM +0800, Dave Chinner wrote:
>> On Thu, Nov 24, 2011 at 11:28:22PM +0100, Jan Kara wrote:
>>> On Mon 21-11-11 19:35:40, Wu Fengguang wrote:
>>>> On Mon, Nov 21, 2011 at 06:01:37PM +0800, Christoph Hellwig wrote:
>>>>> On Mon, Nov 21, 2011 at 05:18:21PM +0800, Wu Fengguang wrote:
>>>>>> From: Nikanth Karthikesan<knikanth@suse.de>
>>>>>>
[...]

>>
>> And one that has already been in use for exactly this purpose for
>> years. Indeed, it's far more flexible because you can give different
>> types of devices different default readahead settings quite easily,
>> and it you can set different defaults for just about any tunable
>> parameter (e.g. readahead, ctq depth, max IO sizes, etc) in the same
>> way.
>
> I'm interested in this usage, too. Would you share some of your rules?
>

FYI - This is an example of a rules Suse delivers in SLES @ s390 for a 
while now. With little modifications it could be used for all Dave 
mentioned above.

cat /etc/udev/rules.d/60-readahead.rules
# 
 
 

# Rules to set an increased default max readahead size for s390 disk 
devices 
 

# This file should be installed in /etc/udev/rules.d 
 
 

# 
 
 

 
 
 

SUBSYSTEM!="block", GOTO="ra_end" 
 
 

 
 
 

ACTION!="add", GOTO="ra_end" 
 
 

# on device add set initial readahead to 512 (instead of in kernel 128) 
 
 

KERNEL=="sd*[!0-9]", ATTR{queue/read_ahead_kb}="512" 
 
 

KERNEL=="dasd*[!0-9]", ATTR{queue/read_ahead_kb}="512" 
 
 


LABEL="ra_end"

-- 

Grusse / regards, Christian Ehrhardt
IBM Linux Technology Center, System z Linux Performance

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
