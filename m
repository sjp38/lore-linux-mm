Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id F0B8482905
	for <linux-mm@kvack.org>; Wed, 11 Mar 2015 22:52:04 -0400 (EDT)
Received: by obcva2 with SMTP id va2so12909385obc.13
        for <linux-mm@kvack.org>; Wed, 11 Mar 2015 19:52:04 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id i5si1178993oeq.104.2015.03.11.19.52.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 11 Mar 2015 19:52:04 -0700 (PDT)
Message-ID: <5500FF4C.2020702@oracle.com>
Date: Wed, 11 Mar 2015 22:51:56 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: btrfs: kernel BUG at fs/btrfs/extent_io.c:676!
References: <543B35D3.6050509@oracle.com> <1413268312.2971.1@mail.thefacebook.com>
In-Reply-To: <1413268312.2971.1@mail.thefacebook.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Mason <clm@fb.com>
Cc: jbacik@fb.com, linux-btrfs@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.cz>

On 10/14/2014 02:31 AM, Chris Mason wrote:
> On Sun, Oct 12, 2014 at 10:15 PM, Sasha Levin <sasha.levin@oracle.com> wrote:
>> Ping?
>>
>> This BUG_ON()ing due to GFP_ATOMIC allocation failure is really silly :(
> 
> Agreed, I have a patch for this in testing.  It didn't make my first pull but I'll get it fixed up.

I've re-enabled fs testing after the discussion at LSF/MM (but mostly
due to Michal's patch), and this issue came right back up.

Any updates?


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
