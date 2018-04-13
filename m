Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4CCB76B0005
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 12:36:03 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id 20so5593354qkd.2
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 09:36:03 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id i26si8116613qtc.356.2018.04.13.09.36.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Apr 2018 09:36:02 -0700 (PDT)
Subject: Re: [PATCH RFC 0/8] mm: online/offline 4MB chunks controlled by
 device driver
References: <20180413131632.1413-1-david@redhat.com>
 <20180413134414.GS17484@dhcp22.suse.cz>
 <85887556-9497-4beb-261e-6cba46794c9c@redhat.com>
 <20180413160331.GZ17484@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Message-ID: <26b2f679-147e-0fe8-63d4-188d3ae77fd5@redhat.com>
Date: Fri, 13 Apr 2018 18:36:01 +0200
MIME-Version: 1.0
In-Reply-To: <20180413160331.GZ17484@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org

On 13.04.2018 18:03, Michal Hocko wrote:
> On Fri 13-04-18 17:02:17, David Hildenbrand wrote:
>> On 13.04.2018 15:44, Michal Hocko wrote:
>>> [If you choose to not CC the same set of people on all patches - which
>>> is sometimes a legit thing to do - then please cc them to the cover
>>> letter at least.]
>>
>> BTW, sorry for that. The list of people to cc was just too big to handle
>> manually, so I used get_maintainers.sh with git for the same time ...
>> something I will most likely avoid next time :)
> 
> I usually have Cc: in all commits and then use the following script as
> --cc-cmd. You just have to git format-patch the series and then
> git send-email --cc-cmd=./cc-cmd.sh *.patch
> + some mailing lists
> 
> #!/bin/bash
> 
> if [[ $1 == *gitsendemail.msg* || $1 == *cover-letter* ]]; then
>         grep '<.*@.*>' -h *.patch | sed 's/^.*: //' | sort | uniq
> fi
> 

Thanks for that, very helpful!

BTW I just found an article stating I did (almost) the right thing:
https://lwn.net/Articles/585782/

But I 100% agree with you, I would also like to see the cover letter of
an RFC patch series :)

-- 

Thanks,

David / dhildenb
