Return-Path: <SRS0=KlKP=WU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4F0A3C3A5A3
	for <linux-mm@archiver.kernel.org>; Sat, 24 Aug 2019 20:23:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1768E20870
	for <linux-mm@archiver.kernel.org>; Sat, 24 Aug 2019 20:23:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1768E20870
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mageia.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 900646B04E8; Sat, 24 Aug 2019 16:23:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B0966B04E9; Sat, 24 Aug 2019 16:23:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7C6C46B04EA; Sat, 24 Aug 2019 16:23:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0184.hostedemail.com [216.40.44.184])
	by kanga.kvack.org (Postfix) with ESMTP id 5CB1F6B04E8
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 16:23:12 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 12998180AD7C1
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 20:23:12 +0000 (UTC)
X-FDA: 75858445824.15.can90_1bd90b8634348
X-HE-Tag: can90_1bd90b8634348
X-Filterd-Recvd-Size: 2481
Received: from mx2.yrkesakademin.fi (mx2.yrkesakademin.fi [85.134.45.195])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 20:23:11 +0000 (UTC)
Subject: Re: [PATCH] Partially revert "mm/memcontrol.c: keep local VM counters
 in sync with the hierarchical ones"
To: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>
CC: Greg KH <greg@kroah.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team
	<Kernel-team@fb.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>,
	Yafang Shao <laoar.shao@gmail.com>
References: <20190817004726.2530670-1-guro@fb.com>
 <20190817063616.GA11747@kroah.com> <20190817191518.GB11125@castle>
 <20190824125750.da9f0aac47cc0a362208f9ff@linux-foundation.org>
From: Thomas Backlund <tmb@mageia.org>
Message-ID: <a082485b-8241-e73d-df09-5c878d181ddc@mageia.org>
Date: Sat, 24 Aug 2019 23:23:07 +0300
MIME-Version: 1.0
In-Reply-To: <20190824125750.da9f0aac47cc0a362208f9ff@linux-foundation.org>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-WatchGuard-Spam-ID: str=0001.0A0C0213.5D619CAF.003E,ss=1,re=0.000,recu=0.000,reip=0.000,cl=1,cld=1,fgs=0
X-WatchGuard-Spam-Score: 0, clean; 0, virus threat unknown
X-WatchGuard-Mail-Client-IP: 85.134.45.195
X-WatchGuard-Mail-From: tmb@mageia.org
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Den 24-08-2019 kl. 22:57, skrev Andrew Morton:
> On Sat, 17 Aug 2019 19:15:23 +0000 Roman Gushchin <guro@fb.com> wrote:
> 
>>>> Fixes: 766a4c19d880 ("mm/memcontrol.c: keep local VM counters in sync with the hierarchical ones")
>>>> Signed-off-by: Roman Gushchin <guro@fb.com>
>>>> Cc: Yafang Shao <laoar.shao@gmail.com>
>>>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>>>> ---
>>>>   mm/memcontrol.c | 8 +++-----
>>>>   1 file changed, 3 insertions(+), 5 deletions(-)
>>>
>>> <formletter>
>>>
>>> This is not the correct way to submit patches for inclusion in the
>>> stable kernel tree.  Please read:
>>>      https://www.kernel.org/doc/html/latest/process/stable-kernel-rules.html
>>> for how to do this properly.
>>
>> Oh, I'm sorry, will read and follow next time. Thanks!
> 
> 766a4c19d880 is not present in 5.2 so no -stable backport is needed, yes?
> 

Unfortunately it got added in 5.2.7, so backport is needed.

--
Thomas


