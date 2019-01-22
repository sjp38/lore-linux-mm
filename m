Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id E97A28E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 11:40:28 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id x82so13569007ita.9
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 08:40:28 -0800 (PST)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id 15si8568427iog.81.2019.01.22.08.40.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 22 Jan 2019 08:40:28 -0800 (PST)
References: <20190116182523.19446-1-logang@deltatee.com>
 <20190122124044.GA11753@kroah.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <9fe43579-77e2-f845-0b30-4fea4ecc27a7@deltatee.com>
Date: Tue, 22 Jan 2019 09:40:17 -0700
MIME-Version: 1.0
In-Reply-To: <20190122124044.GA11753@kroah.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH v25 0/6] Add io{read|write}64 to io-64-atomic headers
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-ntb@googlegroups.com, linux-crypto@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Andy Shevchenko <andy.shevchenko@gmail.com>, =?UTF-8?Q?Horia_Geant=c4=83?= <horia.geanta@nxp.com>



On 2019-01-22 5:40 a.m., Greg Kroah-Hartman wrote:
> On Wed, Jan 16, 2019 at 11:25:17AM -0700, Logan Gunthorpe wrote:
>> This is resend number 6 since the last change to this series.
>>
>> This cleanup was requested by Greg KH back in June of 2017. I've resent the series
>> a couple times a cycle since then, updating and fixing as feedback was slowly
>> recieved some patches were alread accepted by specific arches. In June 2018,
>> Andrew picked the remainder of this up and it was in linux-next for a
>> couple weeks. There were a couple problems that were identified and addressed
>> back then and I'd really like to get the ball rolling again. A year
>> and a half of sending this without much feedback is far too long.
>>
>> @Andrew, can you please pick this set up again so it can get into
>> linux-next? Or let me know if there's something else I should be doing.
> 
> version 25?  That's crazy, this has gone on too long.  I've taken this
> into my char/misc driver tree now, so sorry for the long suffering you
> have gone through for this.

Thanks a lot!

Logan
