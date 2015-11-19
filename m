Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 413736B0254
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 05:50:47 -0500 (EST)
Received: by wmec201 with SMTP id c201so19091302wme.0
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 02:50:46 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id iw7si10486305wjb.105.2015.11.19.02.50.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 19 Nov 2015 02:50:46 -0800 (PST)
Subject: Re: [PATCH] mempolicy: convert the shared_policy lock to a rwlock
References: <alpine.DEB.2.10.1511121301490.10324@chino.kir.corp.google.com>
 <1447777078-135492-1-git-send-email-nzimmer@sgi.com>
 <564C820D.1060105@suse.cz> <564CDA0F.40801@sgi.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <564DA984.2040903@suse.cz>
Date: Thu, 19 Nov 2015 11:50:44 +0100
MIME-Version: 1.0
In-Reply-To: <564CDA0F.40801@sgi.com>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nathan Zimmer <nzimmer@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nadia Yvette Chambers <nyc@holomorphy.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 11/18/2015 09:05 PM, Nathan Zimmer wrote:
>
>
> On 11/18/2015 07:50 AM, Vlastimil Babka wrote:
>> At first glance it seems that RCU would be a good fit here and achieve even
>> better lookup scalability, have you considered it?
>>
>
> Originally that was my plan but when I saw how good the results were
> with the rwlock, I chickened out and took the less prone to mistakes way.
>
> I should also note that the 2% time left in system is not from this lookup
> but another area.

Ah, I see, thanks!
Vlastimil

> Nate
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
