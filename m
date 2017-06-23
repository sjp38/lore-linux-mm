Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id D27A36B0372
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 11:28:51 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id 93so32778750oto.10
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 08:28:51 -0700 (PDT)
Received: from mail-ot0-x234.google.com (mail-ot0-x234.google.com. [2607:f8b0:4003:c0f::234])
        by mx.google.com with ESMTPS id 1si1666647oih.206.2017.06.23.08.28.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jun 2017 08:28:51 -0700 (PDT)
Received: by mail-ot0-x234.google.com with SMTP id 95so33835460ott.3
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 08:28:51 -0700 (PDT)
Subject: Re: Sleeping BUG in khugepaged for i586
References: <968ae9a9-5345-18ca-c7ce-d9beaf9f43b6@lwfinger.net>
 <20170605144401.5a7e62887b476f0732560fa0@linux-foundation.org>
 <caa7a4a3-0c80-432c-2deb-3480df319f65@suse.cz>
 <1e883924-9766-4d2a-936c-7a49b337f9e2@lwfinger.net>
 <9ab81c3c-e064-66d2-6e82-fc9bac125f56@suse.cz>
 <alpine.DEB.2.10.1706071352100.38905@chino.kir.corp.google.com>
 <20170608144831.GA19903@dhcp22.suse.cz>
 <20170623120812.GS5308@dhcp22.suse.cz>
 <66280cc3-6231-8d35-6d9a-113fe2d80409@suse.cz>
 <20170623132558.GC5308@dhcp22.suse.cz>
From: Larry Finger <Larry.Finger@lwfinger.net>
Message-ID: <b358d07c-0a5d-9e0e-9468-8ab74ca05595@lwfinger.net>
Date: Fri, 23 Jun 2017 10:28:49 -0500
MIME-Version: 1.0
In-Reply-To: <20170623132558.GC5308@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On 06/23/2017 08:25 AM, Michal Hocko wrote:
> On Fri 23-06-17 15:13:45, Vlastimil Babka wrote:
>> On 06/23/2017 02:08 PM, Michal Hocko wrote:
>>> On Thu 08-06-17 16:48:31, Michal Hocko wrote:
>>>> On Wed 07-06-17 13:56:01, David Rientjes wrote:
>>>>
>>>> I suspect, so cond_resched seems indeed inappropriate on 32b systems.
>>>
>>> The code still seems to be in the mmotm tree.
>>
>> Even mainline at this point - 338a16ba1549
>>
>>> Are there any plans to fix
>>> this or drop the patch?
>>
>> https://lkml.kernel.org/r/alpine.DEB.2.10.1706191341550.97821@chino.kir.corp.google.com
> 
> Ahh, I have missed that. Thanks!

I also missed that patch. Applying it to my box fixes the scheduling while 
atomic splats and no downside has been detected.

You may add "Reported-and-tested-by: Larry Finger <Larry.Finger@lwfinger.net>".

Thanks for everyone's efforts in fixing this problem.

Larry


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
