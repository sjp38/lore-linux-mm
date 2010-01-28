Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9A8286B0093
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 17:48:10 -0500 (EST)
Received: by bwz7 with SMTP id 7so543123bwz.6
        for <linux-mm@kvack.org>; Thu, 28 Jan 2010 14:48:07 -0800 (PST)
In-Reply-To: <alpine.LFD.2.00.1001281427220.22433@localhost.localdomain>
References: <144AC102-422A-4AA3-864D-F90183837EA3@googlemail.com> <20100128001802.8491e8c1.akpm@linux-foundation.org> <4B61B00D.7070202@zytor.com> <alpine.LFD.2.00.1001281427220.22433@localhost.localdomain>
Mime-Version: 1.0 (Apple Message framework v753.1)
Content-Type: multipart/signed; protocol="application/pgp-signature"; micalg=pgp-sha1; boundary="Apple-Mail-31-796336604"
Message-Id: <F8EDE1FD-DF2A-412C-8A00-7B332A3E1253@googlemail.com>
Content-Transfer-Encoding: 7bit
From: Mathias Krause <minipli@googlemail.com>
Subject: Re: [Security] DoS on x86_64
Date: Thu, 28 Jan 2010 23:47:41 +0100
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, security@kernel.org, "Luck, Tony" <tony.luck@intel.com>, James Morris <jmorris@namei.org>, Mike Waychison <mikew@google.com>, Michael Davidson <md@google.com>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Roland McGrath <roland@redhat.com>
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--Apple-Mail-31-796336604
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed

Am 28.01.2010 um 23:33 schrieb Linus Torvalds:
>>
>> - The actual point of no return in the case of binfmt_elf.c is inside
>> the subroutine flush_old_exec() [which makes sense - the actual  
>> process
>> switch shouldn't be dependent on the binfmt] which isn't subject to
>> compat-level macro munging.
>
> Why worry about it? We already do that additional
>
> 	SET_PERSONALITY(loc->elf_ex);
>
> _after_ the flush_old_exec() call anyway in fs/binfmt_elf.c.
>
> So why not just simply remove the whole early SET_PERSONALITY  
> thing, and
> only keep that later one? The comment about "lookup of the  
> interpreter" is
> known to be irrelevant these days, so why don't we just remove it all?
>
> I have _not_ tested any of this, and maybe there is some crazy  
> reason why
> this won't work, but I'm not seeing it.
>
> I think we do have to do that "task_size" thing (which  
> flush_old_exec()
> also does), because it depends on the personality exactly the same way
> STACK_TOP does. But why isn't the following patch "obviously correct"?

Looks good to me because that's almost exactly the thing we already  
tried, too. But by doing so we just got another Oops when executing a  
32 bit program. But, in fact, we forgot the assignment of TASK_SIZE  
which now clearly makes sense. I guess we can try this tomorrow. I'll  
keep you informed.

Thanks for the patch. Looks promising :)


Greets,
Mathias

--Apple-Mail-31-796336604
content-type: application/pgp-signature; x-mac-type=70674453;
	name=PGP.sig
content-description: Signierter Teil der Nachricht
content-disposition: inline; filename=PGP.sig
content-transfer-encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (Darwin)

iD8DBQFLYhQNZS2uZ5iBxS8RAtvIAKDStT1uzRjwbiC94OQUw/8k6GYYWQCdHD63
D1cwgsKrffAcOhcx82FoBtw=
=e7FJ
-----END PGP SIGNATURE-----

--Apple-Mail-31-796336604--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
