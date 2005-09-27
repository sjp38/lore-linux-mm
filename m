Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e36.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j8RG7SEd024942
	for <linux-mm@kvack.org>; Tue, 27 Sep 2005 12:07:28 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j8RG8cfJ394192
	for <linux-mm@kvack.org>; Tue, 27 Sep 2005 10:08:39 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j8RG8cYQ028912
	for <linux-mm@kvack.org>; Tue, 27 Sep 2005 10:08:38 -0600
Message-ID: <43396E83.7000803@austin.ibm.com>
Date: Tue, 27 Sep 2005 11:08:35 -0500
From: Joel Schopp <jschopp@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/9] defrag helper functions
References: <4338537E.8070603@austin.ibm.com> <43385594.3080303@austin.ibm.com> <C50046EE58FA62242E92877C@[192.168.100.25]>
In-Reply-To: <C50046EE58FA62242E92877C@[192.168.100.25]>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alex Bligh - linux-kernel <linux-kernel@alex.org.uk>
Cc: lhms <lhms-devel@lists.sourceforge.net>, Linux Memory Management List <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

>> +void assign_bit(int bit_nr, unsigned long* map, int value)
> 
> 
> Maybe:
> static inline void assign_bit(int bit_nr, unsigned long* map, int value)
> 
> it's short enough

OK.  It looks like I'll be sending these again based on the feedback I got,
I'll inline that in the next version.  I'd think with it being static that
the compiler would be smart enough to inline it anyway though.

> 
>>  +static struct page *
>> +fallback_alloc(int alloctype, struct zone *zone, unsigned int order)
>> +{
>> +       /* Stub out for seperate review, NULL equates to no fallback*/
>> +       return NULL;
>> +
>> +}
> 
> 
> Maybe "static inline" too.

Except this is only a placeholder for the next patch, where the function
is no longer short.  I'm going to keep it not inline.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
