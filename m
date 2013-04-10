Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 9C6376B0036
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 20:05:21 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id qd14so9318023ieb.14
        for <linux-mm@kvack.org>; Tue, 09 Apr 2013 17:05:20 -0700 (PDT)
Message-ID: <5164ACBB.2040704@gmail.com>
Date: Wed, 10 Apr 2013 08:05:15 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v8 3/3] mm: reinititalise user and admin reserves if memory
 is added or removed
References: <20130408190738.GC2321@localhost.localdomain> <20130408133712.bd327017dec19a2c14e22662@linux-foundation.org> <20130408210039.GA3396@localhost.localdomain> <20130409151906.2ee55116ca9e3abd80a90e3e@linux-foundation.org> <CAF-E8XEq9AE0z472QMWPbY-8YgvDsjx3FhEKRsVx7Bc_=AEn_Q@mail.gmail.com>
In-Reply-To: <CAF-E8XEq9AE0z472QMWPbY-8YgvDsjx3FhEKRsVx7Bc_=AEn_Q@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Shewmaker <agshew@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, alan@lxorguk.ukuu.org.uk, ric.masonn@gmail.com

Hi Andrew,
On 04/10/2013 07:56 AM, Andrew Shewmaker wrote:
> On Tue, Apr 9, 2013 at 4:19 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
>> On Mon, 8 Apr 2013 17:00:40 -0400 Andrew Shewmaker <agshew@gmail.com> wrote:
>>
>>> Should I add the memory notifier code to mm/nommu.c too?
>>> I'm guessing that if a system doesn't have an mmu that it also
>>> won't be hotplugging memory.
>> I doubt if we need to worry about memory hotplug on nommu machines,
>> so just do the minimum which is required to get nommu to compile
>> and link.  That's probably "nothing".
> I haven't gotten myself set up to compile a nommu architecture, so I'll post
> my next version, and work on verifying it compiles and links later. But I
> I probably won't be able to get to that for a week and a half ... I'm leaving
> on my honeymoon in the next couple days :)

How to compile a  nommu architecture? just config in menu config or a 
physical machine?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
