Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id ADD3082BEF
	for <linux-mm@kvack.org>; Sun,  9 Nov 2014 04:35:22 -0500 (EST)
Received: by mail-wi0-f174.google.com with SMTP id d1so7850511wiv.1
        for <linux-mm@kvack.org>; Sun, 09 Nov 2014 01:35:22 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bd10si24006429wjc.128.2014.11.09.01.35.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 09 Nov 2014 01:35:21 -0800 (PST)
Message-ID: <545F3556.5000802@suse.cz>
Date: Sun, 09 Nov 2014 10:35:18 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: Early test: hangs in mm/compact.c w. Linus's 12d7aacab56e9ef185c
References: <00a801cffbd8$434189b0$c9c49d10$@alibaba-inc.com> <1433036.WjB5pb09Zh@xorhgos3.pefnos>
In-Reply-To: <1433036.WjB5pb09Zh@xorhgos3.pefnos>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "P. Christeas" <xrg@linux.gr>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-kernel <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org

On 11/09/2014 09:22 AM, P. Christeas wrote:
> On Sunday 09 November 2014, Hillf Danton wrote:
>> -		return COMPACT_CONTINUE;
>> +		return COMPACT_SKIPPED;
> 
> I guess this one would mitigate against Vlastmil's migration scanner issue, 
> wouldn't it?

Please no, that's a wrong fix. The purpose of compaction is to make the
high-order watermark meet, not give up.

> In that case, I should wait a bit[1] to try the first patch, then revert, try 
> yours and (hopefully) have some results.

I hope my patch will be enough,

> Then, apply both.
> 
> [1] trying to push the vm by loading memory-hungry apps and random load.

Maybe the tools/testing/selftests/vm/transhuge-stress could help

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
