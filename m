Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id F183D6B00DD
	for <linux-mm@kvack.org>; Thu, 24 Oct 2013 13:21:02 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id lf10so2781998pab.34
        for <linux-mm@kvack.org>; Thu, 24 Oct 2013 10:21:02 -0700 (PDT)
Received: from psmtp.com ([74.125.245.195])
        by mx.google.com with SMTP id u9si1543540pbf.53.2013.10.24.10.21.01
        for <linux-mm@kvack.org>;
        Thu, 24 Oct 2013 10:21:02 -0700 (PDT)
Received: by mail-wg0-f47.google.com with SMTP id c11so2691895wgh.14
        for <linux-mm@kvack.org>; Thu, 24 Oct 2013 10:20:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <F901C6708ADD5241BD39AFE3DD266906013746E21BDC@seldmbx01.corpusers.net>
References: <1381273137-14680-1-git-send-email-tim.bird@sonymobile.com>
	<000001419e9e3e33-67807dca-e435-43ee-88bc-3ead54a83762-000000@email.amazonses.com>
	<F901C6708ADD5241BD39AFE3DD266906013746E21BDC@seldmbx01.corpusers.net>
Date: Thu, 24 Oct 2013 20:20:58 +0300
Message-ID: <CAOJsxLG9_YZKq1Z4tdjmWKjNL3L1E7nXBhzPHNorUNF1U9q7mA@mail.gmail.com>
Subject: Re: [PATCH] slub: proper kmemleak tracking if CONFIG_SLUB_DEBUG disabled
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Bobniev, Roman" <Roman.Bobniev@sonymobile.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "frowand.list@gmail.com" <frowand.list@gmail.com>, =?ISO-8859-1?Q?Andersson=2C_Bj=F6rn?= <Bjorn.Andersson@sonymobile.com>, "tbird20d@gmail.com" <tbird20d@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Bird, Tim" <Tim.Bird@sonymobile.com>, "cl@linux.com" <cl@linux.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On Wed, Oct 23, 2013 at 2:52 PM, Bobniev, Roman
<Roman.Bobniev@sonymobile.com> wrote:
>> On Tue, 8 Oct 2013, Tim Bird wrote:
>>
>> > It also fixes a bug where kmemleak was only partially enabled in some
>> > configurations.
>>
>> Acked-by: Christoph Lameter <cl@linux.com>
>
> Could you help me, who the maintainer is that
> puts this patch in a tree and pushes it to mainline?
> Do we wait on some additional Ack from someone?

That would be me - sorry for the delay!

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
