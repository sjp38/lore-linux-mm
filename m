Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 86C356B01D2
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 03:12:48 -0400 (EDT)
Message-ID: <4C1727EC.2020500@redhat.com>
Date: Tue, 15 Jun 2010 10:12:44 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC/T/D][PATCH 2/2] Linux/Guest cooperative unmapped page cache
 control
References: <20100608155153.3749.31669.sendpatchset@L34Z31A.ibm.com> <4C10B3AF.7020908@redhat.com> <20100610142512.GB5191@balbir.in.ibm.com> <1276214852.6437.1427.camel@nimitz> <20100611045600.GE5191@balbir.in.ibm.com> <4C15E3C8.20407@redhat.com> <20100614084810.GT5191@balbir.in.ibm.com> <1276528376.6437.7176.camel@nimitz> <20100614165853.GW5191@balbir.in.ibm.com> <1276535371.6437.7417.camel@nimitz> <20100614171624.GY5191@balbir.in.ibm.com>
In-Reply-To: <20100614171624.GY5191@balbir.in.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, kvm <kvm@vger.kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 06/14/2010 08:16 PM, Balbir Singh wrote:
> * Dave Hansen<dave@linux.vnet.ibm.com>  [2010-06-14 10:09:31]:
>
>    
>> On Mon, 2010-06-14 at 22:28 +0530, Balbir Singh wrote:
>>      
>>> If you've got duplicate pages and you know
>>> that they are duplicated and can be retrieved at a lower cost, why
>>> wouldn't we go after them first?
>>>        
>> I agree with this in theory.  But, the guest lacks the information about
>> what is truly duplicated and what the costs are for itself and/or the
>> host to recreate it.  "Unmapped page cache" may be the best proxy that
>> we have at the moment for "easy to recreate", but I think it's still too
>> poor a match to make these patches useful.
>>
>>      
> That is why the policy (in the next set) will come from the host. As
> to whether the data is truly duplicated, my experiments show up to 60%
> of the page cache is duplicated.

Isn't that incredibly workload dependent?

We can't expect the host admin to know whether duplication will occur or 
not.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
