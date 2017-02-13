Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8ED446B0388
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 10:43:11 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id z134so44609782lff.5
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 07:43:11 -0800 (PST)
Received: from SELDSEGREL01.sonyericsson.com (seldsegrel01.sonyericsson.com. [37.139.156.29])
        by mx.google.com with ESMTPS id h15si2203111ljh.94.2017.02.13.07.43.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Feb 2017 07:43:10 -0800 (PST)
Subject: Re: [PATCH 0/3 staging-next] android: Lowmemmorykiller task tree
References: <df828d70-3962-2e43-0512-1777a9842bb2@sonymobile.com>
 <20170210102732.GB10054@dhcp22.suse.cz>
From: peter enderborg <peter.enderborg@sonymobile.com>
Message-ID: <5579dead-092d-2ce2-a9d4-f2b50721f0dc@sonymobile.com>
Date: Mon, 13 Feb 2017 16:42:42 +0100
MIME-Version: 1.0
In-Reply-To: <20170210102732.GB10054@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: devel@driverdev.osuosl.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, =?UTF-8?Q?Arve_Hj=c3=b8nnev=c3=a5g?= <arve@android.com>, Riley Andrews <riandrews@android.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org

On 02/10/2017 11:27 AM, Michal Hocko wrote:
> [I have only now see this cover - it answers some of the questions I've
>  had to specific patches. It would be really great if you could use git
>  send-email to post patch series - it just does the right thing(tm)]
>
> On Thu 09-02-17 14:21:40, peter enderborg wrote:
>> Lowmemorykiller efficiency problem and a solution.
>>
>> Lowmemorykiller in android has a severe efficiency problem. The basic
>> problem is that the registered shrinker gets called very often without
>>  anything actually happening.
> Which is an inherent problem because lkml doesn't belong to shrinkers
> infrastructure.

Not really what this patch address.  I see it as a problem with shrinker
that there no slow-path-free (scan/count) where it should belong.
This patch address a specific problem where lot of cpu are wasted
in low memory conditions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
