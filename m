Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 054546B0044
	for <linux-mm@kvack.org>; Tue, 20 Jan 2009 11:31:56 -0500 (EST)
Received: by bwz12 with SMTP id 12so9527641bwz.4
        for <linux-mm@kvack.org>; Tue, 20 Jan 2009 08:29:12 -0800 (PST)
Message-ID: <8c5a844a0901200826n714e1891n23dd48208a6a6746@mail.gmail.com>
Date: Tue, 20 Jan 2009 18:26:52 +0200
From: "Daniel Lowengrub" <lowdanie@gmail.com>
Subject: Re: [PATCH 2.6.28 1/2] memory: improve find_vma
In-Reply-To: <20090120072659.B0A6.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <8c5a844a0901170912l48bab3fuc306bd77622bb53f@mail.gmail.com>
	 <20090120072659.B0A6.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> Hi
>
>> -     /* linked list of VM areas per task, sorted by address */
>> +     /* doubly linked list of VM areas per task, sorted by address */
>>       struct vm_area_struct *vm_next;
>> +     struct vm_area_struct *vm_prev;
>
> if you need "doublly linked list", why don't you use list.h?

list.h implements a circular linked list which is harder to integrate
into the existing code which in many places uses the fact that the
last element in the list points to null. First I want to check if it's
a good idea in general, if it is then I'll try to use the list.h
implementation.
Do you think that the idea is worth building on?  Is there any special
reason that I'm not aware of that this wasn't done originally?
Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
