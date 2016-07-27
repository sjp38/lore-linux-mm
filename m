Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 600B56B0253
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 17:33:32 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id p85so4303993lfg.3
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 14:33:32 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 16si9054740wjr.129.2016.07.27.14.33.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Jul 2016 14:33:30 -0700 (PDT)
From: NeilBrown <neilb@suse.com>
Date: Thu, 28 Jul 2016 07:33:19 +1000
Subject: Re: [dm-devel] [RFC PATCH 2/2] mm, mempool: do not throttle PF_LESS_THROTTLE tasks
In-Reply-To: <20160727182411.GE21859@dhcp22.suse.cz>
References: <1468831164-26621-1-git-send-email-mhocko@kernel.org> <1468831285-27242-1-git-send-email-mhocko@kernel.org> <1468831285-27242-2-git-send-email-mhocko@kernel.org> <87oa5q5abi.fsf@notabene.neil.brown.name> <20160722091558.GF794@dhcp22.suse.cz> <878twt5i1j.fsf@notabene.neil.brown.name> <20160725083247.GD9401@dhcp22.suse.cz> <87lh0n4ufs.fsf@notabene.neil.brown.name> <20160727182411.GE21859@dhcp22.suse.cz>
Message-ID: <87eg6e4vhc.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, Mikulas Patocka <mpatocka@redhat.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Ondrej Kozina <okozina@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Jul 28 2016, Michal Hocko wrote:

> On Wed 27-07-16 13:43:35, NeilBrown wrote:
>> On Mon, Jul 25 2016, Michal Hocko wrote:
>>=20
>> > On Sat 23-07-16 10:12:24, NeilBrown wrote:
> [...]
>> So should there be a limit on dirty
>> pages in the swap cache just like there is for dirty pages in any
>> filesystem (the max_dirty_ratio thing) ??
>> Maybe there is?
>
> There is no limit AFAIK. We are relying that the reclaim is throttled
> when necessary.

Is that a bit indirect?  It is hard to tell without a clear big-picture.
Something to keep in mind anyway.

>
>> I think we'd end up with cleaner code if we removed the cute-hacks.  And
>> we'd be able to use 6 more GFP flags!!  (though I do wonder if we really
>> need all those 26).
>
> Well, maybe we are able to remove those hacks, I wouldn't definitely
> be opposed.  But right now I am not even convinced that the mempool
> specific gfp flags is the right way to go.

I'm not suggesting a mempool-specific gfp flag.  I'm suggesting a
transient-allocation gfp flag, which would be quite useful for mempool.

Can you give more details on why using a gfp flag isn't your first choice
for guiding what happens when the system is trying to get a free page
:-?

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXmSifAAoJEDnsnt1WYoG56KkQAIZP7dc2h3fAnBCcPvMXdCGE
RC7X4mV1+Ksp4MCxYeopPzPWZH2bIlNpKfjRCkywvy0aqB7a+s3Zyul67YI2/RDo
CXR01pFeZMZhWfEFvDpmZro5JSS1Ypei4CA4xrMQ++G+yHTUqeMKcwpZR3e0XQff
L4fqc5oLIJSpq99eL/bAWuH+kHLpPBxvIvUxufARF3OUsqhJXgKYVWB6xYNjmo19
QoWKyjI/FdOPP8kXdERWVBfKpF4jxReUeVf3fS9Qy/TA12ogsl1iWZdrpeU+NECt
ChVvp/AdljYdTLGq7KafIeF9O3gu+qU5CPjBHPMlDsT7IKi2HUPC+OF0oc2Z+GCh
bJRX40nphNgG7Em8XMVhlb+kznVYAKg1gnB+D13S1+CR+laEl51xb3UKkBKd64xb
IMIdV3UEB+nlYcTEYdUpg/iRaYOHygUblRQArLeP9N91dsk8vyxFVFKeETG9ymWO
felLwByWOHPNu+bGQEwb2O7GZQKIvercdLdAuncg/BonARjOXSOrQjk4+KZ4h77u
llzY1qI3FvTPSOocqoqaUOfptY+6+2RaCLevQlyGYOgahHDauTxYorKxoKOr3O/W
lrk2d5ENq8sJlSh6i7YBPJ68wUbDCwx2cSuivWCl0skKKiit86My3slbsViafFJN
BbjJ1BOa+QCv4Wvc8/9X
=rBEF
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
