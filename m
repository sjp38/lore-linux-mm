References: <200511232333.jANNX9g23967@unix-os.sc.intel.com> <cone.1132788946.360368.25446.501@kolivas.org> <200511232338.54794.s0348365@sms.ed.ac.uk>
Message-ID: <cone.1132789223.709733.25446.501@kolivas.org>
From: Con Kolivas <kernel@kolivas.org>
Subject: Re: Kernel BUG at mm/rmap.c:491
Date: Thu, 24 Nov 2005 10:40:23 +1100
Mime-Version: 1.0
Content-Type: multipart/signed;
    boundary="=_mimegpg-kolivas.org-25446-1132789223-0004";
    micalg=pgp-sha1; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alistair John Strachan <s0348365@sms.ed.ac.uk>
Cc: Kenneth W <kenneth.w.chen@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This is a MIME GnuPG-signed message.  If you see this text, it means that
your E-mail or Usenet software does not support MIME signed messages.

--=_mimegpg-kolivas.org-25446-1132789223-0004
Content-Type: text/plain; format=flowed; charset="US-ASCII"
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

Alistair John Strachan writes:

> On Wednesday 23 November 2005 23:35, Con Kolivas wrote:
>> Chen, Kenneth W writes:
>> > Con Kolivas wrote on Wednesday, November 23, 2005 3:24 PM
>> >
>> >> Chen, Kenneth W writes:
>> >> > Has people seen this BUG_ON before?  On 2.6.15-rc2, x86-64.
>> >> >
>> >> > Pid: 16500, comm: cc1 Tainted: G    B 2.6.15-rc2 #3
>> >> >
>> >> > Pid: 16651, comm: sh Tainted: G    B 2.6.15-rc2 #3
>> >>
>> >>                        ^^^^^^^^^^
>> >>
>> >> Please try to reproduce it without proprietary binary modules linked in.
>> >
>> > ???, I'm not using any modules at all.
>> >
>> > [albat]$ /sbin/lsmod
>> > Module                  Size  Used by
>> > [albat]$
>> >
>> >
>> > Also, isn't it 'P' indicate proprietary module, not 'G'?
>> > line 159: kernel/panic.c:
>> >
>> >         snprintf(buf, sizeof(buf), "Tainted: %c%c%c%c%c%c",
>> >                 tainted & TAINT_PROPRIETARY_MODULE ? 'P' : 'G',
>>
>> Sorry it's not proprietary module indeed. But what is tainting it?
> 
> Probably a prior oops or some other marked error condition.

My humble apologies! Force of habit when seeing tainted message which 
comes up so often :(

Con


--=_mimegpg-kolivas.org-25446-1132789223-0004
Content-Type: application/pgp-signature
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBDhP3nZUg7+tp6mRURAkSUAJ432H6r09YpcXziYYOirBoafLg7hgCeM5q5
EHnhkNtU/5g945HWQ5hCNUI=
=4ynq
-----END PGP SIGNATURE-----

--=_mimegpg-kolivas.org-25446-1132789223-0004--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
