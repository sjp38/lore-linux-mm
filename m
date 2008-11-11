Message-ID: <4919FF41.30800@qumranet.com>
Date: Tue, 11 Nov 2008 23:55:13 +0200
From: Izik Eidus <izik@qumranet.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] Add replace_page(), change the mapping of pte from
 one page into another
References: <1226409701-14831-1-git-send-email-ieidus@redhat.com> <1226409701-14831-2-git-send-email-ieidus@redhat.com> <1226409701-14831-3-git-send-email-ieidus@redhat.com> <20081111114555.eb808843.akpm@linux-foundation.org> <20081111210655.GG10818@random.random> <Pine.LNX.4.64.0811111522150.27767@quilx.com> <4919FB95.4060105@redhat.com> <Pine.LNX.4.64.0811111544350.28346@quilx.com>
In-Reply-To: <Pine.LNX.4.64.0811111544350.28346@quilx.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Avi Kivity <avi@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, chrisw@redhat.com, izike@qumranet.com
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Tue, 11 Nov 2008, Avi Kivity wrote:
>
>   
>> Christoph Lameter wrote:
>>     
>>> page migration requires the page to be on the LRU. That could be changed
>>> if you have a different means of isolating a page from its page tables.
>>>
>>>       
>> Isn't rmap the means of isolating a page from its page tables?  I guess I'm
>> misunderstanding something.
>>     
>
> In order to migrate a page one first has to make sure that userspace and
> the kernel cannot access the page in any way. User space must be made to
> generate page faults and all kernel references must be accounted for and
> not be in use.
>   
This is really not the case for ksm,
in ksm we allow the page to be accessed all the time, we dont have to 
swap the page
like migrate.c is doing...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
