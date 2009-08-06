Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 6202F6B005A
	for <linux-mm@kvack.org>; Thu,  6 Aug 2009 05:17:16 -0400 (EDT)
Message-ID: <4A7AA0CF.2020700@redhat.com>
Date: Thu, 06 Aug 2009 12:22:23 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
References: <20090805024058.GA8886@localhost> <4A79C70C.6010200@redhat.com> <9EECC02A4CC333418C00A85D21E89326B651C1FE@azsmsx502.amr.corp.intel.com> <4A79D88E.2040005@redhat.com> <9EECC02A4CC333418C00A85D21E89326B651C21C@azsmsx502.amr.corp.intel.com>
In-Reply-To: <9EECC02A4CC333418C00A85D21E89326B651C21C@azsmsx502.amr.corp.intel.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>
Cc: Rik van Riel <riel@redhat.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 08/05/2009 10:18 PM, Dike, Jeffrey G wrote:
>> How did you create that 128M memory compartment?
>>
>> Did you use cgroups on the host system?
>>      
>
> Yup.
>
>    
>> How much memory do you give your virtual machine?
>>
>> That is, how much memory does it think it has?
>>      
>
> 256M.
>    

So you're effectively running a 256M guest on a 128M host?

Do cgroups have private active/inactive lists?

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
