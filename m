Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 054016B0031
	for <linux-mm@kvack.org>; Thu,  3 Apr 2014 12:57:11 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa1so2128123pad.14
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 09:57:11 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id ua2si3360529pab.77.2014.04.03.09.57.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Apr 2014 09:57:10 -0700 (PDT)
From: Mitchel Humpherys <mitchelh@codeaurora.org>
Subject: Re: [PATCH v2] mm: convert some level-less printks to pr_*
References: <1395942859-11611-1-git-send-email-mitchelh@codeaurora.org>
	<1395942859-11611-2-git-send-email-mitchelh@codeaurora.org>
	<alpine.DEB.2.10.1403311334060.3313@nuc>
	<1396291441.21529.52.camel@joe-AO722>
	<alpine.DEB.2.10.1404031132310.21658@nuc>
Date: Thu, 03 Apr 2014 09:57:11 -0700
In-Reply-To: <alpine.DEB.2.10.1404031132310.21658@nuc> (Christoph Lameter's
	message of "Thu, 3 Apr 2014 11:33:15 -0500 (CDT)")
Message-ID: <vnkwha6a1hco.fsf@mitchelh-linux.qualcomm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Joe Perches <joe@perches.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Apr 03 2014 at 09:33:15 AM, Christoph Lameter <cl@linux.com> wrote:
> On Mon, 31 Mar 2014, Joe Perches wrote:
>
>> On Mon, 2014-03-31 at 13:35 -0500, Christoph Lameter wrote:
>> > On Thu, 27 Mar 2014, Mitchel Humpherys wrote:
>> >
>> > > diff --git a/mm/slub.c b/mm/slub.c
>> []
>> > > @@ -9,6 +9,8 @@
>> > >   * (C) 2011 Linux Foundation, Christoph Lameter
>> > >   */
>> > >
>> > > +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
>> >
>> > This is implicitly used by some macros? If so then please define this
>> > elsewhere. I do not see any use in slub.c of this one.
>>
>> Hi Christoph
>>
>> All the pr_<level> macros use it.
>>
>> from include/linux/printk.h:
>
> Ok then why do you add the definition to slub.c?

Ah that was an oversight on my part after changing to pr_cont. I'll send
a v3 that removes the pr_fmt. Or I could send a v3 that leaves the
pr_fmt but changes the printk that the pr_cont's are continuing (at the
top of note_cmpxchg_failure) to pr_info, but that wouldn't be consistent
with the rest of the file, which is using hand-tagged printk's.

I don't know if it's worthwhile to convert all of the hand-tagged
printk's to the pr_ macros, but if so I can do that in a separate patch.

-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
