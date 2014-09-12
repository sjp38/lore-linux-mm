Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 6C3B66B0035
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 00:44:22 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so381859pab.15
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 21:44:22 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id fk4si5249889pbb.236.2014.09.11.21.44.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Sep 2014 21:44:19 -0700 (PDT)
Message-ID: <54127A16.4030701@zytor.com>
Date: Thu, 11 Sep 2014 21:44:06 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH v8 07/10] x86, mpx: decode MPX instruction to get bound
 violation information
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com> <1410425210-24789-8-git-send-email-qiaowei.ren@intel.com> <alpine.DEB.2.10.1409120015030.4178@nanos> <5412230A.6090805@intel.com> <541223B1.5040705@zytor.com> <alpine.DEB.2.10.1409120133330.4178@nanos>
In-Reply-To: <alpine.DEB.2.10.1409120133330.4178@nanos>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Dave Hansen <dave.hansen@intel.com>, Qiaowei Ren <qiaowei.ren@intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/11/2014 04:37 PM, Thomas Gleixner wrote:
>>
>> Specifically because marshaling the data in and out of the generic
>> decoder was more complex than a special-purpose decoder.
>
> I did not look at that detail and I trust your judgement here, but
> that is in no way explained in the changelog.
>
> This whole patchset is a pain to review due to half baken changelogs
> and complete lack of a proper design description.
>

I'm not wedded to that concept, by the way, but using the generic parser 
had a whole bunch of its own problems, including the fact that you're 
getting bytes from user space.

It might be worthwhile to compare the older patchset which did use the 
generic parser to make sure that it actually made sense.

	-hpa




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
