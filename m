Message-ID: <479858CE.3060704@qumranet.com>
Date: Thu, 24 Jan 2008 11:22:22 +0200
From: Avi Kivity <avi@qumranet.com>
MIME-Version: 1.0
Subject: Re: [kvm-devel] [RFC][PATCH 3/5] ksm source code
References: <4794C477.3090708@qumranet.com> <20080124072432.GQ3627@sequoia.sous-sol.org> <4798554D.1010300@qumranet.com>
In-Reply-To: <4798554D.1010300@qumranet.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Izik Eidus <izike@qumranet.com>
Cc: Chris Wright <chrisw@sous-sol.org>, kvm-devel <kvm-devel@lists.sourceforge.net>, andrea@qumranet.com, dor.laor@qumranet.com, linux-mm@kvack.org, yaniv@qumranet.com
List-ID: <linux-mm.kvack.org>

Izik Eidus wrote:
>>  
>>> struct ksm *ksm;
>>>     
>>
>> static
>>
>>   
>
> yes


Actually the entire contents of 'struct ksm' should be module static 
variables.

-- 
Any sufficiently difficult bug is indistinguishable from a feature.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
