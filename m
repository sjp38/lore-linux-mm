Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A83A9280850
	for <linux-mm@kvack.org>; Sun, 21 May 2017 06:45:53 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b86so19238906wmi.6
        for <linux-mm@kvack.org>; Sun, 21 May 2017 03:45:53 -0700 (PDT)
Received: from mout.web.de (mout.web.de. [212.227.17.11])
        by mx.google.com with ESMTPS id t24si9324246wrb.61.2017.05.21.03.45.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 May 2017 03:45:52 -0700 (PDT)
Subject: Re: Using best practices for big software change possibilities
References: <05101843-91f6-3243-18ea-acac8e8ef6af@users.sourceforge.net>
 <bae25b04-2ce2-7137-a71c-50d7b4f06431@users.sourceforge.net>
 <20170521084734.GB1456@katana>
 <7bd4b458-6f6e-416b-97a9-b1b3d0840144@users.sourceforge.net>
 <20170521095654.bzpaa2obfszrajgb@ninjato>
 <82cfcf3e-0089-0629-f10c-e01346487f6a@users.sourceforge.net>
 <20170521102750.ljgvdw2btuks3tqf@ninjato>
From: SF Markus Elfring <elfring@users.sourceforge.net>
Message-ID: <be7ee31a-8623-2f23-4dea-ffb323169b52@users.sourceforge.net>
Date: Sun, 21 May 2017 12:45:46 +0200
MIME-Version: 1.0
In-Reply-To: <20170521102750.ljgvdw2btuks3tqf@ninjato>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wolfram Sang <wsa@the-dreams.de>
Cc: linux-mm@kvack.org, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>, LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org

>> How do you think about to resolve them by additional means besides mail exchange?
> 
> That can work.

I am curious to find out which other communication means could really help here.


> E.g. meeting at conferences often solved mail communication problems.

I find my resources too limited at the moment to attend conferences on site.

How are the chances for further clarification by ordinary telephone calls?


> For now, I still wonder why you were unsure about grouping the changes
> into one patch?

I am varying the patch granularity for affected software areas to some degree.
But I came also places along where I got an impression for higher uncertainty.


> Maybe there is something to be learned?

This is also generally possible.

Would you like to extend the scope for the change pattern around questionable
error messages from a single source file to whole subsystem trees in Linux?

Regards,
Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
