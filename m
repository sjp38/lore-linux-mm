Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5DCEB6B0006
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 11:53:35 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id g22-v6so8029280ioh.5
        for <linux-mm@kvack.org>; Mon, 04 Jun 2018 08:53:35 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id s196-v6si393286ita.124.2018.06.04.08.53.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 04 Jun 2018 08:53:33 -0700 (PDT)
Subject: Re: [PATCH] docs/admin-guide/mm: add high level concepts overview
References: <20180529113725.GB13092@rapoport-lnx>
 <285dd950-0b25-dba3-60b6-ceac6075fb48@infradead.org>
 <20180604122235.GB15196@rapoport-lnx>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <30155b1b-cc7f-9203-49dc-c1235e204012@infradead.org>
Date: Mon, 4 Jun 2018 08:53:25 -0700
MIME-Version: 1.0
In-Reply-To: <20180604122235.GB15196@rapoport-lnx>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Jonathan Corbet <corbet@lwn.net>, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 06/04/2018 05:22 AM, Mike Rapoport wrote:
> Hi Randy,
> 
> Thanks for the review! I always have trouble with articles :)
> The patch below addresses most of your comments.
> 
> On Fri, Jun 01, 2018 at 05:09:38PM -0700, Randy Dunlap wrote:
>> On 05/29/2018 04:37 AM, Mike Rapoport wrote:
>>> Hi,
>>>
>>> From 2d3ec7ea101a66b1535d5bec4acfc1e0f737fd53 Mon Sep 17 00:00:00 2001
>>> From: Mike Rapoport <rppt@linux.vnet.ibm.com>
>>> Date: Tue, 29 May 2018 14:12:39 +0300
>>> Subject: [PATCH] docs/admin-guide/mm: add high level concepts overview
>>>
>>> The are terms that seem obvious to the mm developers, but may be somewhat
> 
> Huh, I afraid it's to late to change the commit message :(

Sure.

>>   There are [or: These are]
>>
>>> obscure for, say, less involved readers.
>>>
>>> The concepts overview can be seen as an "extended glossary" that introduces
>>> such terms to the readers of the kernel documentation.
>>>
>>> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
>>> ---
>>>  Documentation/admin-guide/mm/concepts.rst | 222 ++++++++++++++++++++++++++++++
>>>  Documentation/admin-guide/mm/index.rst    |   5 +
>>>  2 files changed, 227 insertions(+)
>>>  create mode 100644 Documentation/admin-guide/mm/concepts.rst
>>>
>>> diff --git a/Documentation/admin-guide/mm/concepts.rst b/Documentation/admin-guide/mm/concepts.rst
>>> new file mode 100644
>>> index 0000000..291699c
>>> --- /dev/null
>>> +++ b/Documentation/admin-guide/mm/concepts.rst
> 
> [...]
> 
>>> +All this makes dealing directly with physical memory quite complex and
>>> +to avoid this complexity a concept of virtual memory was developed.
>>> +
>>> +The virtual memory abstracts the details of physical memory from the
>>
>>        virtual memory {system, implementation} abstracts
>>
>>> +application software, allows to keep only needed information in the
>>
>>                software, allowing the VM to keep only needed information in the
>>
>>> +physical memory (demand paging) and provides a mechanism for the
>>> +protection and controlled sharing of data between processes.
>>> +
> 
> My intention was "virtual memory concept allows ... and provides ..."
> I didn't want to repeat "concept", to I've just omitted it.
> 
> Somehow, I don't feel that "system" or "implementation" fit here...

OK.  Thanks for the update.

> Subject: [PATCH] docs/admin-guide/mm/concepts.rst: grammar fixups

> The patch is mostly about adding 'a' and 'the' and updating indentation.

I would say that it's mostly about improving readability.

Acked-by: Randy Dunlap <rdunlap@infradead.org>


-- 
~Randy
