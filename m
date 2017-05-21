Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9C8F2280850
	for <linux-mm@kvack.org>; Sun, 21 May 2017 06:12:46 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 10so19140620wml.4
        for <linux-mm@kvack.org>; Sun, 21 May 2017 03:12:46 -0700 (PDT)
Received: from mout.web.de (mout.web.de. [212.227.17.11])
        by mx.google.com with ESMTPS id d24si8594683wrb.106.2017.05.21.03.12.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 May 2017 03:12:45 -0700 (PDT)
Subject: Re: Using best practices for big software change possibilities
References: <05101843-91f6-3243-18ea-acac8e8ef6af@users.sourceforge.net>
 <bae25b04-2ce2-7137-a71c-50d7b4f06431@users.sourceforge.net>
 <20170521084734.GB1456@katana>
 <7bd4b458-6f6e-416b-97a9-b1b3d0840144@users.sourceforge.net>
 <20170521095654.bzpaa2obfszrajgb@ninjato>
From: SF Markus Elfring <elfring@users.sourceforge.net>
Message-ID: <82cfcf3e-0089-0629-f10c-e01346487f6a@users.sourceforge.net>
Date: Sun, 21 May 2017 12:12:39 +0200
MIME-Version: 1.0
In-Reply-To: <20170521095654.bzpaa2obfszrajgb@ninjato>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wolfram Sang <wsa@the-dreams.de>
Cc: linux-mm@kvack.org, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>, LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org

> Have you read my LWN article "Best practices for a big patch series"?
> 
> https://lwn.net/Articles/585782/

Yes.


>> This can also happen as a side effect if such a source code search pattern
>> will point hundreds of places out for further software development considerations.
>> How would you prefer to clarify the remaining update candidates there?
> 
> Maybe the article mentioned can provice further guidance?

Partly, yes.

I am trying to achieve some software improvements also for special change patterns.
This approach can trigger corresponding communication difficulties.
How do you think about to resolve them by additional means besides mail exchange?

Regards,
Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
