Date: Wed, 16 May 2001 12:11:04 -0400
Message-Id: <200105161611.MAA20338@www22.ureach.com>
From: Kapish K <kapish@ureach.com>
Reply-to: <kapish@ureach.com>
Subject: Re: RE: Kernel Debugger
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Frey <martin.frey@compaq.com>, amarnath.jolad@wipro.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,
	Saw this posting on the mailing list. Haev you used SGI's lkcd
as well? Would anybody know how different mcore and lkcd are? in
terms of how they perform or in terms of performance benefits,
etc.?
any pointers? I have ben trying to understand lkcd and wold like
to compare against mcore as well.
TIA



________________________________________________
Get your own "800" number
Voicemail, fax, email, and a lot more
http://www.ureach.com/reg/tag


---- On   Wed, 16, Martin Frey (frey@scs.ch) wrote:

> Hi
> >Is there any kernel debugger for linux like 
> >adb/crash/kadb. If so,  from
> >where can I get them.
> >
> http://oss.missioncriticallinux.com
> 
> mcore and crash work fine for me. I used it on
> Alpha, but is is supposed to work on Intel and
> PowerPC as well.
> The patches are against 2.2.16 and 2.4.0testX,
> but applying it on 2.4.2 is easy.
> I can send you a diff for 2.4.2 if you need.
> 
> Regards,
> 
> Martin Frey
> 
> -- 
> Supercomputing Systems AG       email: frey@scs.ch
> Martin Frey                     web:  
http://www.scs.ch/~frey/
> at Compaq Computer Corporation  phone: +1 603 884 4266
> ZKO2-3P09, 110 Spit Brook Road, Nashua, NH 03062
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
