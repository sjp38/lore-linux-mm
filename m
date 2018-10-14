Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0774B6B0005
	for <linux-mm@kvack.org>; Sun, 14 Oct 2018 03:20:28 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id k21-v6so1033061ede.12
        for <linux-mm@kvack.org>; Sun, 14 Oct 2018 00:20:27 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o6-v6si2478831ejb.176.2018.10.14.00.20.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Oct 2018 00:20:26 -0700 (PDT)
Subject: Re: [Bug 201377] New: Kernel BUG under memory pressure: unable to
 handle kernel NULL pointer dereference at 00000000000000f0
From: Vlastimil Babka <vbabka@suse.cz>
References: <bug-201377-27@https.bugzilla.kernel.org/>
 <20181012155533.2f15a8bb35103aa1fa87962e@linux-foundation.org>
 <20181012155641.b3a1610b4ddcd37e374115d4@linux-foundation.org>
 <9f77da23-2a46-29a5-6aa7-fe9e7cca1056@suse.cz>
Message-ID: <555fbd1f-4ac9-0b58-dcd4-5dc4380ff7ca@suse.cz>
Date: Sun, 14 Oct 2018 09:17:41 +0200
MIME-Version: 1.0
In-Reply-To: <9f77da23-2a46-29a5-6aa7-fe9e7cca1056@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, leozinho29_eu@hotmail.com
Cc: linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Daniel Colascione <dancol@google.com>, Alexey Dobriyan <adobriyan@gmail.com>

On 10/13/18 2:57 PM, Vlastimil Babka wrote:
> On 10/13/18 12:56 AM, Andrew Morton wrote:
>> (cc linux-mm, argh)
>>
>> On Fri, 12 Oct 2018 15:55:33 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:
>>
>>>
>>> (switched to email.  Please respond via emailed reply-to-all, not via the
>>> bugzilla web interface).
>>>
>>> Vlastimil, it looks like your August 21 smaps changes are failing. 
>>> This one is pretty urgent, please.
> 
> Thanks, will look in few hours. Glad that there will be rc8...

I think I found it, and it seems the bug was there all the time for smaps_rollup.
Dunno why it was hit only now. Please test?

----8<----
