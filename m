Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E269A6B025E
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 04:50:37 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id u144so82944216wmu.1
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 01:50:37 -0800 (PST)
Received: from tschil.ethgen.ch (tschil.ethgen.ch. [5.9.7.51])
        by mx.google.com with ESMTPS id m6si51908792wjx.216.2017.01.04.01.50.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jan 2017 01:50:36 -0800 (PST)
Date: Wed, 4 Jan 2017 10:50:31 +0100
From: Klaus Ethgen <Klaus+lkml@ethgen.de>
Subject: Re: [KERNEL] Re: [KERNEL] Re: [KERNEL] Re: Bug 4.9 and
 memorymanagement
Message-ID: <20170104095031.oama5lmzjh6gkh6g@ikki.ethgen.ch>
References: <20161225205251.nny6k5wol2s4ufq7@ikki.ethgen.ch>
 <20161226110053.GA16042@dhcp22.suse.cz>
 <20161227112844.GG1308@dhcp22.suse.cz>
 <20161230111135.GG13301@dhcp22.suse.cz>
 <20161230165230.th274as75pzjlzkk@ikki.ethgen.ch>
 <20161230172358.GA4266@dhcp22.suse.cz>
 <20170104080639.GB25453@dhcp22.suse.cz>
 <20170104081527.hq5q4ngevcl3c7k6@ikki.ethgen.ch>
 <20170104083117.GC25453@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1; x-action=pgp-signed
In-Reply-To: <20170104083117.GC25453@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512

Hi Michal,

Am Mi den  4. Jan 2017 um  9:31 schrieb Michal Hocko:
> On Wed 04-01-17 09:15:27, Klaus Ethgen wrote:
> > Hi Michal,
> > 
> > Am Mi den  4. Jan 2017 um  9:06 schrieb Michal Hocko:
> > 
> > > > Just try to run with the patch and do what you do normally. If you do
> > > > not see any OOMs in few days it should be sufficient evidence. From your
> > > > previous logs it seems you hit the problem quite early after few hours
> > > > as far as I remember.
> > > 
> > > Did you have chance to run with the patch? I would like to post it for
> > > inclusion and feedback from you is really useful.
> > 
> > Yes. It runs since 2017-01-01 and without problems until today.
> > 
> > I think it looks good but that is just my feeling. I don't know if it is
> > to early to say that.
> > 
> > I also did some heavy git repository actions to big repositories. The
> > system is in swap and still no OOMs.
> 
> OK, that is a good indication. I will add your Reported-by to the patch
> and if you feel comfortable also Tested-by.

Yes, thats great by me. Just use Klaus@Ethgen.de (without +lkml). :-)
Thanks for working on that issue.

I'd like to give it until end of the day. Then it is full 3 days.

The longest time I had it running with broken version was once over 2
days, once once 3 days and once even 4 days (with sleeps in between).

However, then, I didn't give it heavy memory load.

Regards
   Klaus
- -- 
Klaus Ethgen                                       http://www.ethgen.ch/
pub  4096R/4E20AF1C 2011-05-16            Klaus Ethgen <Klaus@Ethgen.ch>
Fingerprint: 85D4 CA42 952C 949B 1753  62B3 79D0 B06F 4E20 AF1C
-----BEGIN PGP SIGNATURE-----
Comment: Charset: ISO-8859-1

iQGzBAEBCgAdFiEEMWF28vh4/UMJJLQEpnwKsYAZ9qwFAlhsxWEACgkQpnwKsYAZ
9qwqmgv/cuufn7mtqg9yb5T6deskFHbK2vyt7ezHKtwfHh+cDbI0P0gpBg0ThO18
WMgQ7PJonywRrGucFVRqxu214b1QAwBav0Nzkz43791exzBrM7AXtd1JX/bLYHEP
Z128e3eMADvd0Tf5Wqu5g5cvf0nZ+tQsXlgx+SqcXxeO6RpUTH5EBlGLNpkhHjyV
InPN8SWlwpCCDQyYh3vhEzl02PnyT4EkmKTpATvCUhI8WlglKYmsDKcEw/YM5gCA
cByq9wwiXeqbKnrSZAejJnK/VtzOrTkDU7t2BsN1hK45UO94Lj+nc2wtmPEukvry
IUYhK/x/wg0a8N4WfAR76Yprg4cKAfuDCtHPq2/b92UcuJA2d4KR+12Uidh9RL9C
JOSPkiIhBm1YOcGFzosddSomBKPvg89yEB8LLtbnb8mM9T8UTBSF3pmyKuzc1jnh
8FXkla+HTHUB/pbUStlU4avtbPzDR3pRCKITPuATTLsc2oipj2x43UuTwtBnRlD+
7ANZfjIj
=Ns+2
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
