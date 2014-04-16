Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 254686B0031
	for <linux-mm@kvack.org>; Tue, 15 Apr 2014 20:05:48 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id kx10so10186259pab.19
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 17:05:47 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id qf5si11676711pac.129.2014.04.15.17.05.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Apr 2014 17:05:47 -0700 (PDT)
From: Mitchel Humpherys <mitchelh@codeaurora.org>
Subject: Re: [PATCH v2] mm: convert some level-less printks to pr_*
References: <1395942859-11611-1-git-send-email-mitchelh@codeaurora.org>
	<1395942859-11611-2-git-send-email-mitchelh@codeaurora.org>
	<20140414155526.96b0832bf4660c026bc3a1d9@linux-foundation.org>
	<vnkwvbuaywki.fsf@mitchelh-linux.qualcomm.com>
Date: Tue, 15 Apr 2014 17:05:53 -0700
In-Reply-To: <vnkwvbuaywki.fsf@mitchelh-linux.qualcomm.com> (Mitchel
	Humpherys's message of "Tue, 15 Apr 2014 16:58:21 -0700")
Message-ID: <vnkwmwfmyw7y.fsf@mitchelh-linux.qualcomm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Joe Perches <joe@perches.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Apr 15 2014 at 04:58:21 PM, Mitchel Humpherys <mitchelh@codeaurora.org> wrote:
> On Mon, Apr 14 2014 at 03:55:26 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
>> And all of this should be described and justified in the changelog,
>> please.
>
> Will send a v3 shortly. Thanks for your comments.

Make that a v4, I actually already sent a v3. You'd think I could get a
printk change right on v1 :). We'll get there.

-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
