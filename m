Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 4FC626B0038
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 08:00:57 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so154019382wic.1
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 05:00:56 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gy7si4255541wib.14.2015.09.09.05.00.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 09 Sep 2015 05:00:55 -0700 (PDT)
Subject: Re: [PATCH] mlock.2: mlock2.2: Add entry to for new mlock2 syscall
References: <1440787391-30298-1-git-send-email-emunson@akamai.com>
 <20150831092300.GE29723@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55F01F75.8080706@suse.cz>
Date: Wed, 9 Sep 2015 14:00:53 +0200
MIME-Version: 1.0
In-Reply-To: <20150831092300.GE29723@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Eric B Munson <emunson@akamai.com>
Cc: mtk.manpages@gmail.com, Jonathan Corbet <corbet@lwn.net>, linux-man@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/31/2015 11:23 AM, Michal Hocko wrote:
> On Fri 28-08-15 14:43:11, Eric B Munson wrote:
>> Update the mlock.2 man page with information on mlock2() and the new
>> mlockall() flag MCL_ONFAULT.
>>
>> Signed-off-by: Eric B Munson <emunson@akamai.com>
>> Cc: Michal Hocko <mhocko@suse.cz>
>
> Acked-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

>
> I am not familiar with the format much so I am just looking at the text
> and that looks reasonable to me.

Same here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
