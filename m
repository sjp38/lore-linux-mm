Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 8851B6B0096
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 16:32:29 -0500 (EST)
Received: by bwz7 with SMTP id 7so481270bwz.6
        for <linux-mm@kvack.org>; Thu, 28 Jan 2010 13:32:25 -0800 (PST)
In-Reply-To: <20100128001802.8491e8c1.akpm@linux-foundation.org>
References: <144AC102-422A-4AA3-864D-F90183837EA3@googlemail.com> <20100128001802.8491e8c1.akpm@linux-foundation.org>
Mime-Version: 1.0 (Apple Message framework v753.1)
Content-Type: multipart/signed; protocol="application/pgp-signature"; micalg=pgp-sha1; boundary="Apple-Mail-26-791791335"
Message-Id: <D2BE4854-1ED6-4259-8A57-A555DC6F62AF@googlemail.com>
Content-Transfer-Encoding: 7bit
From: Mathias Krause <minipli@googlemail.com>
Subject: Re: [Security] DoS on x86_64
Date: Thu, 28 Jan 2010 22:31:56 +0100
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, security@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Mike Waychison <mikew@google.com>, Michael Davidson <md@google.com>, "Luck, Tony" <tony.luck@intel.com>, Roland McGrath <roland@redhat.com>, James Morris <jmorris@namei.org>
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--Apple-Mail-26-791791335
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed

Am 28.01.2010 um 09:18 schrieb Andrew Morton:

> On Thu, 28 Jan 2010 08:34:02 +0100 Mathias Krause  
> <minipli@googlemail.com> wrote:
>
>> I found by accident an reliable way to panic the kernel on an x86_64
>> system. Since this one can be triggered by an unprivileged user I
>> CCed security@kernel.org. I also haven't found a corresponding bug on
>> bugzilla.kernel.org. So, what to do to trigger the bug:
>>
>> 1. Enable core dumps
>> 2. Start an 32 bit program that tries to execve() an 64 bit program
>> 3. The 64 bit program cannot be started by the kernel because it
>> can't find the interpreter, i.e. execve returns with an error
>> 4. Generate a segmentation fault
>> 5. panic
>
> hrm, isn't this the same as "failed exec() leaves caller with  
> incorrect
> personality", discussed in December? afacit nothing happened as a  
> result
> of that.

Yes, indeed it is. Thanks for the pointer.

--Apple-Mail-26-791791335
content-type: application/pgp-signature; x-mac-type=70674453;
	name=PGP.sig
content-description: Signierter Teil der Nachricht
content-disposition: inline; filename=PGP.sig
content-transfer-encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (Darwin)

iD8DBQFLYgJMZS2uZ5iBxS8RAnKIAJ0VP4bo9NUhAoZ1XVogi5rEZ/7TZACeOG9r
Z7FRS79+o3pjAMht9RSrqaQ=
=UGm8
-----END PGP SIGNATURE-----

--Apple-Mail-26-791791335--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
