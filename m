Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 550126001DA
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 17:09:16 -0500 (EST)
Received: by bwz7 with SMTP id 7so516236bwz.6
        for <linux-mm@kvack.org>; Thu, 28 Jan 2010 14:09:13 -0800 (PST)
In-Reply-To: <alpine.LFD.2.00.1001281354230.22433@localhost.localdomain>
References: <144AC102-422A-4AA3-864D-F90183837EA3@googlemail.com> <alpine.LFD.2.00.1001280902340.22433@localhost.localdomain> <2BCD2997-7101-4BFF-82CC-A5EC2F4F8E9E@googlemail.com> <alpine.LFD.2.00.1001281354230.22433@localhost.localdomain>
Mime-Version: 1.0 (Apple Message framework v753.1)
Content-Type: multipart/signed; protocol="application/pgp-signature"; micalg=pgp-sha1; boundary="Apple-Mail-29-794000324"
Message-Id: <FE79E0D4-6783-432E-8A2A-D239B113FD85@googlemail.com>
Content-Transfer-Encoding: 7bit
From: Mathias Krause <minipli@googlemail.com>
Subject: Re: [Security] DoS on x86_64
Date: Thu, 28 Jan 2010 23:08:45 +0100
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, security@kernel.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--Apple-Mail-29-794000324
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed

Am 28.01.2010 um 22:58 schrieb Linus Torvalds:
>>> I don't get a core-dump, even though it says I do:
>>>
>>> 	[torvalds@nehalem amd64_killer]$ ./run.sh
>>> 	* look at /proc/22768/maps and press enter to continue...
>>> 	* executing ./poison...
>>> 	* that failed (No such file or directory), as expected :)
>>> 	* look at /proc/22768/maps and press enter to continue...
>>
>> Have you looked at /proc/PID/maps at this point? On our machine  
>> the [vdso] was
>> gone and [vsyscall] was there instead -- at an 64 bit address of  
>> course.
>
> Yup. That's the behavior I see - except I see the [vdso] thing in both
> cases.
>
> So I agree that it has become a 64-bit process, and that the whole
> personality crap is buggy.

So it's not really fixed yet :)

> I just don't see the crash.

This at least gives us the hint, the core writing code maybe was  
modified in a way it does some additionally check that prevents the  
kernel to crash in this case. But the crash should be reproducible on  
the latest stable, 2.6.32.6 -- at least this is what I would read out  
of the statement of hpa made.

>> Since this is a production server I would rather stick to a stable  
>> kernel and
>> just pick the commit that fixes the issue. Can you please tell me  
>> which one
>> that may be?
>
> I'd love to be able to say that it's been fixed in so-and-so, but  
> since I
> don't know what the oops is, I have a hard time even guessing  
> _whether_ it
> has actually been fixed or not, or whether the reason I don't see  
> it is
> something else totally unrelated.

I'll look into the last commits to fs/exec.c and see if I can find  
something that suits to my assumption.

Greets,
Mathias

--Apple-Mail-29-794000324
content-type: application/pgp-signature; x-mac-type=70674453;
	name=PGP.sig
content-description: Signierter Teil der Nachricht
content-disposition: inline; filename=PGP.sig
content-transfer-encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (Darwin)

iD8DBQFLYgrtZS2uZ5iBxS8RAvU1AKCFADJXQXMpU71PwofwLtsgLcw8+ACgoWvB
Q6ZOtIuhAX5u+1peGGyu9G4=
=GGvs
-----END PGP SIGNATURE-----

--Apple-Mail-29-794000324--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
