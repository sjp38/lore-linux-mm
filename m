Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 241F76B0095
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 16:49:53 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id 16so116848fgg.8
        for <linux-mm@kvack.org>; Thu, 28 Jan 2010 13:49:50 -0800 (PST)
In-Reply-To: <alpine.LFD.2.00.1001280902340.22433@localhost.localdomain>
References: <144AC102-422A-4AA3-864D-F90183837EA3@googlemail.com> <alpine.LFD.2.00.1001280902340.22433@localhost.localdomain>
Mime-Version: 1.0 (Apple Message framework v753.1)
Content-Type: multipart/signed; protocol="application/pgp-signature"; micalg=pgp-sha1; boundary="Apple-Mail-28-792839838"
Message-Id: <2BCD2997-7101-4BFF-82CC-A5EC2F4F8E9E@googlemail.com>
Content-Transfer-Encoding: 7bit
From: Mathias Krause <minipli@googlemail.com>
Subject: Re: [Security] DoS on x86_64
Date: Thu, 28 Jan 2010 22:49:24 +0100
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, security@kernel.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--Apple-Mail-28-792839838
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed

Am 28.01.2010 um 18:10 schrieb Linus Torvalds:

>
>
> On Thu, 28 Jan 2010, Mathias Krause wrote:
>>
>> 1. Enable core dumps
>> 2. Start an 32 bit program that tries to execve() an 64 bit program
>> 3. The 64 bit program cannot be started by the kernel because it  
>> can't find
>> the interpreter, i.e. execve returns with an error
>> 4. Generate a segmentation fault
>> 5. panic
>
> Hmm. Nothing happens for me when I try this. I just get the expected
> SIGSEGV. Can you post the oops/panic message?
>

I currently have no access to the actual machine but will send it to  
you tomorrow.

> I don't get a core-dump, even though it says I do:
>
> 	[torvalds@nehalem amd64_killer]$ ./run.sh
> 	* look at /proc/22768/maps and press enter to continue...
> 	* executing ./poison...
> 	* that failed (No such file or directory), as expected :)
> 	* look at /proc/22768/maps and press enter to continue...

Have you looked at /proc/PID/maps at this point? On our machine the  
[vdso] was gone and [vsyscall] was there instead -- at an 64 bit  
address of course.

> 	* fasten your seat belt, generating segmentation fault...
> 	./run.sh: line 6: 22768 Segmentation fault      (core dumped) ./ 
> amd64_killer ./poison
>
> This is with current -git (I don't have any machines around running  
> older
> kernels), so maybe we fixed it already, of course.

Since this is a production server I would rather stick to a stable  
kernel and just pick the commit that fixes the issue. Can you please  
tell me which one that may be?


Greets,
Mathias

--Apple-Mail-28-792839838
content-type: application/pgp-signature; x-mac-type=70674453;
	name=PGP.sig
content-description: Signierter Teil der Nachricht
content-disposition: inline; filename=PGP.sig
content-transfer-encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (Darwin)

iD8DBQFLYgZkZS2uZ5iBxS8RAkR2AKDoRbxw0SBmpViEHwcXRugedn3FWwCdFmHe
RcN9V8e6Bd9ay4Y1+nuQkns=
=92/j
-----END PGP SIGNATURE-----

--Apple-Mail-28-792839838--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
