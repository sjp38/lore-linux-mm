Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 67AD96B0047
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 14:41:55 -0500 (EST)
Received: by iwn29 with SMTP id 29so1782513iwn.27
        for <linux-mm@kvack.org>; Thu, 04 Mar 2010 11:41:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <f875e2fe1003041020t7cbab2c2x585df9b2dfc10dd2@mail.gmail.com>
References: <f875e2fe1003032052p944f32ayfe9fe8cfbed056d4@mail.gmail.com>
	 <20100303224245.ae8d1f7a.akpm@linux-foundation.org>
	 <87f94c371003040617t4a4fcd0dt1c9fc0f50e6002c4@mail.gmail.com>
	 <4B8FC6AC.4060801@teksavvy.com>
	 <f875e2fe1003040733h20d5523ex5d18b84f47fee8c7@mail.gmail.com>
	 <4B8FF2C3.1060808@teksavvy.com>
	 <f875e2fe1003041020t7cbab2c2x585df9b2dfc10dd2@mail.gmail.com>
Date: Thu, 4 Mar 2010 14:41:53 -0500
Message-ID: <87f94c371003041141y1bcd30fdkdca7349eea5930b4@mail.gmail.com>
Subject: Re: Linux kernel - Libata bad block error handling to user mode
	program
From: Greg Freemyer <greg.freemyer@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: s ponnusa <foosaa@gmail.com>
Cc: Mark Lord <kernel@teksavvy.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-ide@vger.kernel.org, Jens Axboe <jens.axboe@oracle.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 4, 2010 at 1:20 PM, s ponnusa <foosaa@gmail.com> wrote:
> SMART data consists only the count of remapped sectors, seek failures,
> raw read error rate, uncorrectable sector counts, crc errors etc., and
> technically one should be aware of the error during write operation as
> well.
>
> As per the ATAPI specifications\


ATAPI?

What sort of device is this?

Greg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
