Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6DB826B0005
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 11:02:19 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id u9so5715947qtg.2
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 08:02:19 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 186si739625qkj.365.2018.04.13.08.02.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Apr 2018 08:02:18 -0700 (PDT)
Subject: Re: [PATCH RFC 0/8] mm: online/offline 4MB chunks controlled by
 device driver
References: <20180413131632.1413-1-david@redhat.com>
 <20180413134414.GS17484@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Message-ID: <85887556-9497-4beb-261e-6cba46794c9c@redhat.com>
Date: Fri, 13 Apr 2018 17:02:17 +0200
MIME-Version: 1.0
In-Reply-To: <20180413134414.GS17484@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org

On 13.04.2018 15:44, Michal Hocko wrote:
> [If you choose to not CC the same set of people on all patches - which
> is sometimes a legit thing to do - then please cc them to the cover
> letter at least.]

BTW, sorry for that. The list of people to cc was just too big to handle
manually, so I used get_maintainers.sh with git for the same time ...
something I will most likely avoid next time :)

-- 

Thanks,

David / dhildenb
