Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 6559C6B004D
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 06:07:35 -0500 (EST)
Received: by iwn34 with SMTP id 34so4723417iwn.12
        for <linux-mm@kvack.org>; Tue, 17 Nov 2009 03:07:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091117015655.GA8683@suse.de>
References: <2df346410911151938r1eb5c5e4q9930ac179d61ef01@mail.gmail.com>
	 <20091117015655.GA8683@suse.de>
Date: Tue, 17 Nov 2009 19:07:33 +0800
Message-ID: <2df346410911170307y1eb1f209se01d0cf456bb0bc6@mail.gmail.com>
Subject: Re: [BUG]2.6.27.y some contents lost after writing to mmaped file
From: JiSheng Zhang <jszhang3@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Greg KH <gregkh@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org
List-ID: <linux-mm.kvack.org>

Hi Greg,

2009/11/17 Greg KH <gregkh@suse.de>:
>>
>> Tested kernel is 2.6.27.12 and 2.6.27.39
>
> Does this work on any kernel you have tested? =A0Or is it a regression?

I have tested on both 2.6.27.12 and 2.6.27.39, fsx-linux all failed.

>
>> Tested file system: ext3, tmpfs.
>> IMHO, it impacts all file systems.
>>
>> Some fsx-linux log is:
>>
>> READ BAD DATA: offset =3D 0x2771b, size =3D 0xa28e
>> OFFSET =A0GOOD =A0 =A0BAD =A0 =A0 RANGE
> Are you sure that the LTP is correct? =A0It wouldn't be the first time it
> wasn't...

hmmm, I read the source again, IMHO it is correct.

>
> thanks,
>
> greg k-h
>

One more findings: If I add "return" at the beginning of domapwrite,
no fail found yet.

Regards,
Jisheng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
