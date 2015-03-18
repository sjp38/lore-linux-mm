Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id 36B1A6B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 10:40:42 -0400 (EDT)
Received: by webcq43 with SMTP id cq43so34053978web.2
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 07:40:41 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ez12si4171378wid.0.2015.03.18.07.40.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Mar 2015 07:40:40 -0700 (PDT)
Message-ID: <55098E66.7030609@suse.cz>
Date: Wed, 18 Mar 2015 15:40:38 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH V5] Allow compaction of unevictable pages
References: <1426267597-25811-1-git-send-email-emunson@akamai.com> <550332CE.7040404@redhat.com> <20150313190915.GA12589@akamai.com> <20150313201954.GB28848@dhcp22.suse.cz> <5506ACEC.9010403@suse.cz> <20150316134956.GA15324@akamai.com>
In-Reply-To: <20150316134956.GA15324@akamai.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <cl@linux.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linux API <linux-api@vger.kernel.org>

On 03/16/2015 02:49 PM, Eric B Munson wrote:
> On Mon, 16 Mar 2015, Vlastimil Babka wrote:
>
>> [CC += linux-api@]
>>
>> Since this is a kernel-user-space API change, please CC linux-api@.
>> The kernel source file Documentation/SubmitChecklist notes that all
>> Linux kernel patches that change userspace interfaces should be CCed
>> to linux-api@vger.kernel.org, so that the various parties who are
>> interested in API changes are informed. For further information, see
>> https://urldefense.proofpoint.com/v2/url?u=https-3A__www.kernel.org_doc_man-2Dpages_linux-2Dapi-2Dml.html&d=AwIC-g&c=96ZbZZcaMF4w0F4jpN6LZg&r=aUmMDRRT0nx4IfILbQLv8xzE0wB9sQxTHI3QrQ2lkBU&m=GUotTNnv26L0HxtXrBgiHqu6kwW3ufx2_TQpXIA216c&s=IFFYQ7Zr-4SIaF3slOZqiSP_noyva42kCwVRxxDm5wo&e=
>
> Added to the Cc list, thanks.
>
>>
>>
>> On 03/13/2015 09:19 PM, Michal Hocko wrote:
>>> On Fri 13-03-15 15:09:15, Eric B Munson wrote:
>>>> On Fri, 13 Mar 2015, Rik van Riel wrote:
>>>>
>>>>> On 03/13/2015 01:26 PM, Eric B Munson wrote:
>>>>>
>>>>>> --- a/mm/compaction.c
>>>>>> +++ b/mm/compaction.c
>>>>>> @@ -1046,6 +1046,8 @@ typedef enum {
>>>>>>   	ISOLATE_SUCCESS,	/* Pages isolated, migrate */
>>>>>>   } isolate_migrate_t;
>>>>>>
>>>>>> +int sysctl_compact_unevictable;
>>
>> A comment here would be useful I think, as well as explicit default
>> value. Maybe also __read_mostly although I don't know how much that
>> matters.
>
> I am going to sit on V6 for a couple of days incase anyone from rt wants
> to chime in.  But these will be in V6.
>
>>
>> I also wonder if it might be confusing that "compact_memory" is a
>> write-only trigger that doesn't even show under "sysctl -a", while
>> "compact_unevictable" is a read/write setting. But I don't have a
>> better suggestion right now.
>
> Does allow_unevictable_compaction sound better?  It feels too much like

For sorting purposes, maybe compact_unevictable_allowed?

> variable naming conventions from other languages which seems to
> encourage verbosity to me, but does indicate a difference from
> compact_memory.

If it sounds too awkward/long and nobody else has better suggestion, 
then just keep it as "compact_unevictable".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
