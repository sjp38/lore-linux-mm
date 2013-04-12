Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id C87B16B0027
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 22:12:02 -0400 (EDT)
Message-ID: <51676D6B.1020202@redhat.com>
Date: Thu, 11 Apr 2013 22:11:55 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Hardware initiated paging of user process
 pages, hardware access to the CPU page tables of user processes
References: <5114DF05.7070702@mellanox.com> <CANN689Ff6vSu4ZvHek4J4EMzFG7EjF-Ej48hJKV_4SrLoj+mCA@mail.gmail.com> <CAH3drwaACy5KFv_2ozEe35u1Jpxs0f6msKoW=3_0nrWZpJnO4w@mail.gmail.com> <5163D119.80603@gmail.com> <20130409142156.GA1909@gmail.com> <5164C365.70302@gmail.com> <20130410204507.GA3958@gmail.com> <5166310D.4020100@gmail.com> <20130411183828.GA6696@gmail.com> <51676941.3050802@gmail.com>
In-Reply-To: <51676941.3050802@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Jerome Glisse <j.glisse@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Haggai Eran <haggaie@mellanox.com>, lsf-pc@lists.linux-foundation.org, Liran Liss <liranl@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Roland Dreier <roland@purestorage.com>, linux-mm@kvack.org, Or Gerlitz <ogerlitz@mellanox.com>, Michel Lespinasse <walken@google.com>

On 04/11/2013 09:54 PM, Simon Jeons wrote:
> Hi Jerome,
> On 04/12/2013 02:38 AM, Jerome Glisse wrote:
>> On Thu, Apr 11, 2013 at 11:42:05AM +0800, Simon Jeons wrote:

>> Tomorrow world we want gpu to be able to access memory that the
>> application
>> allocated through a simple malloc and we want the kernel to be able to
>> recycly any page at any time because of memory pressure or because kernel
>> decide to do so.
>>
>> That's just what we want to do. To achieve so we are getting hw that
>> can do
>> pagefault. No change to kernel core mm code (some improvement might be
>> made).
>
> The memory disappear since you have a reference(gup) against it,
> correct? Tomorrow world you want the page fault trigger through iommu
> driver that call get_user_pages, it also will take a reference(since gup
> is called), isn't it? Anyway, assume tomorrow world doesn't take a
> reference, we don't need care page which used by GPU is reclaimed?

The GPU and CPU may each have a different page table format.
The kernel will need to keep both in sync. That is one of the
things this discussion is about.

For performance reasons, it may also make sense to locate some
of the application's data in the GPU's own memory, so it does
not have to cross the PCIE bus every time it needs to load the
data. That requires memory coherency code in the kernel.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
