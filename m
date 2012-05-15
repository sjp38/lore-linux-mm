Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 408396B00F0
	for <linux-mm@kvack.org>; Tue, 15 May 2012 11:18:19 -0400 (EDT)
Received: by wgbdt14 with SMTP id dt14so5285517wgb.26
        for <linux-mm@kvack.org>; Tue, 15 May 2012 08:18:17 -0700 (PDT)
MIME-Version: 1.0
Reply-To: konrad@darnok.org
In-Reply-To: <4FB06604.5060608@kernel.org>
References: <1336027242-372-4-git-send-email-minchan@kernel.org>
	<4FA28EFD.5070002@vflare.org>
	<4FA33E89.6080206@kernel.org>
	<alpine.LFD.2.02.1205071038090.2851@tux.localdomain>
	<4FA7C2BC.2090400@vflare.org>
	<4FA87837.3050208@kernel.org>
	<731b6638-8c8c-4381-a00f-4ecd5a0e91ae@default>
	<4FA9C127.5020908@kernel.org>
	<d8fb8c73-0fd4-47c6-a9bb-ba3573569d63@default>
	<4FAC5C87.3060504@kernel.org>
	<20120511190643.GB3785@phenom.dumpdata.com>
	<4FB06604.5060608@kernel.org>
Date: Tue, 15 May 2012 11:18:17 -0400
Message-ID: <CAPbh3ruaPQ+6s9t4KULYr2TdTUhUQNfQhFUt=C2jpvAvh+QTsQ@mail.gmail.com>
Subject: Re: [PATCH 4/4] zsmalloc: zsmalloc: align cache line size
From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

>>> I think it's not urgent than zs_handle mess.
>>
>> I am having a hard time parsing that. Are you saying that
>> this is not as important as the zs_handle fixup? I think
>> that is what you meant, but what to make sure.
>
>
> Yes. I think zs_hande fixup is top priority for me than any other stuff I pointed out.

What else is should we put on the TODO?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
