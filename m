Message-ID: <479824EA.7070603@qumranet.com>
Date: Thu, 24 Jan 2008 07:40:58 +0200
From: Avi Kivity <avi@qumranet.com>
MIME-Version: 1.0
Subject: Re: [kvm-devel] [RFC][PATCH 0/5] Memory merging driver for Linux
References: <4794C2E1.8040607@qumranet.com> <20080123231037.GA3629@sequoia.sous-sol.org>
In-Reply-To: <20080123231037.GA3629@sequoia.sous-sol.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Wright <chrisw@sous-sol.org>
Cc: Izik Eidus <izike@qumranet.com>, kvm-devel <kvm-devel@lists.sourceforge.net>, andrea@qumranet.com, dor.laor@qumranet.com, linux-mm@kvack.org, yaniv@qumranet.com
List-ID: <linux-mm.kvack.org>

Chris Wright wrote:
> * Izik Eidus (izike@qumranet.com) wrote:
>   
>> this module find this identical data (pages) and merge them into one 
>> single page
>> this new page is write protected so in any case the guest will try to 
>> write to it do_wp_page will duplicate the page
>>     
>
> What happens if you've merged more pages than you can recover on write
> faults?
>   

You start to swap.  Just like Linux when you start to write on fork()ed 
memory.

A management application may start taking measures, like inflating 
balloons and migrating to other hosts, but swapping is needed as a last 
resort measure.

-- 
Any sufficiently difficult bug is indistinguishable from a feature.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
