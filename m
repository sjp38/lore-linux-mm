Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2BEA36B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 02:34:18 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id n1so12000367pgt.4
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 23:34:18 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id q12si8919760pgp.149.2017.10.02.23.34.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Oct 2017 23:34:16 -0700 (PDT)
Subject: Re: 4.14-rc2 on thinkpad x220: out of memory when inserting mmc card
References: <20170905194739.GA31241@amd> <20171001093704.GA12626@amd>
 <20171001102647.GA23908@amd>
 <201710011957.ICF15708.OOLOHFSQMFFVJt@I-love.SAKURA.ne.jp>
 <72c93a69-610f-027e-c028-379b97b6f388@intel.com> <20171002084131.GA24414@amd>
 <CACRpkdbatrt0Uxf8653iiV-OKkgcc0Ziog_L4oDVTJVNqtNN0Q@mail.gmail.com>
 <20171002130353.GA25433@amd>
From: Adrian Hunter <adrian.hunter@intel.com>
Message-ID: <184b3552-851c-7015-dd80-76f6eebc33cc@intel.com>
Date: Tue, 3 Oct 2017 09:27:30 +0300
MIME-Version: 1.0
In-Reply-To: <20171002130353.GA25433@amd>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>, Linus Walleij <linus.walleij@linaro.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>, linux-mm@kvack.org

On 02/10/17 16:03, Pavel Machek wrote:
> On Mon 2017-10-02 14:06:03, Linus Walleij wrote:
>> On Mon, Oct 2, 2017 at 10:41 AM, Pavel Machek <pavel@ucw.cz> wrote:
>>
>>>> Bounce buffers are being removed from v4.15
>>
>> As Adrian states, this would make any last bugs go away. I would
>> even consider putting this patch this into fixes if it solves the problem.
>>
>>> although you may experience
>>>> performance regression with that:
>>>>
>>>>       https://marc.info/?l=linux-mmc&m=150589778700551
>>>
>>> Hmm. The performance of this is already pretty bad, I really hope it
>>> does not get any worse.
>>
>> Did you use bounce buffers? Those were improving performance on
>> some laptops with TI or Ricoh host controllers and nothing else was
>> ever really using it (as can be seen from the commit).
> 
> Thinkpad X220... how do I tell if I was using them? I believe so,
> because I uncovered bug in them before.

You are certainly using bounce buffers.  What does lspci -knn show?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
