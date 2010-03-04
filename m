Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 80D7D6B009E
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 13:20:14 -0500 (EST)
Received: by vws6 with SMTP id 6so32486vws.14
        for <linux-mm@kvack.org>; Thu, 04 Mar 2010 10:20:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4B8FF2C3.1060808@teksavvy.com>
References: <f875e2fe1003032052p944f32ayfe9fe8cfbed056d4@mail.gmail.com>
	 <20100303224245.ae8d1f7a.akpm@linux-foundation.org>
	 <87f94c371003040617t4a4fcd0dt1c9fc0f50e6002c4@mail.gmail.com>
	 <4B8FC6AC.4060801@teksavvy.com>
	 <f875e2fe1003040733h20d5523ex5d18b84f47fee8c7@mail.gmail.com>
	 <4B8FF2C3.1060808@teksavvy.com>
Date: Thu, 4 Mar 2010 13:20:11 -0500
Message-ID: <f875e2fe1003041020t7cbab2c2x585df9b2dfc10dd2@mail.gmail.com>
Subject: Re: Linux kernel - Libata bad block error handling to user mode
	program
From: s ponnusa <foosaa@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mark Lord <kernel@teksavvy.com>
Cc: Greg Freemyer <greg.freemyer@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-ide@vger.kernel.org, Jens Axboe <jens.axboe@oracle.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

SMART data consists only the count of remapped sectors, seek failures,
raw read error rate, uncorrectable sector counts, crc errors etc., and
technically one should be aware of the error during write operation as
well.

As per the ATAPI specifications, the media will report error for both
read / write operations. It times out / sends out error code for both
read and write operations. Correct me if I am wrong. What happens if
all the available free sectors are remapped and there are no more
sectors to map? In that atleast the drive should return an error
right? When using the O_DIRECT more, the i/o error, media bad,
softreset, hardreset error messages are starting to fill up dmesg
almost immediately after the write call.

It just tries in a continous loop and then finally returns success
(even without remapping). I don't know how to change the behavior of
libata / or other such driver which does it. All I want to do it to
know the error in my program while it is reporting it in the syslog at
kernel / driver level.

Thank you.

On Thu, Mar 4, 2010 at 12:49 PM, Mark Lord <kernel@teksavvy.com> wrote:
> On 03/04/10 10:33, foo saa wrote:
> ..
>>
>> hdparm is good, but I don't want to use the internal ATA SECURE ERASE
>> because I can never get the amount of bad sectors the drive had.
>
> ..
>
> Oh.. but isn't that information in the S.M.A.R.T. data ??
>
> You'll not find the bad sectors by writing -- a true WRITE nearly never
> reports a media error. =A0Instead, the drive simply remaps to a good sect=
or
> on the fly and returns success.
>
> Generally, only READs report media errors.
>
> Cheers
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
