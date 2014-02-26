Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id F14AA6B0073
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 03:05:09 -0500 (EST)
Received: by mail-we0-f178.google.com with SMTP id q59so1304283wes.23
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 00:05:09 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fw15si536981wic.33.2014.02.26.00.05.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 26 Feb 2014 00:05:08 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
From: Alexander Graf <agraf@suse.de>
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH] ksm: Expose configuration via sysctl
Date: Wed, 26 Feb 2014 15:49:20 +0800
Message-Id: <33B27E4E-11A7-45FD-B708-C2B380AB6608@suse.de>
References: <1393284484-27637-1-git-send-email-agraf@suse.de> <20140225171528.GJ4407@cmpxchg.org> <alpine.LSU.2.11.1402251652230.979@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1402251652230.979@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Hugh Dickins <hughd@google.com>, Izik Eidus <izik.eidus@ravellosystems.com>, Andrea Arcangeli <aarcange@redhat.com>, Kay Sievers <kay@vrfy.org>, Dave Hansen <dave.hansen@intel.com>



> Am 26.02.2014 um 09:05 schrieb Hugh Dickins <hughd@google.com>:
>=20
>> On Tue, 25 Feb 2014, Johannes Weiner wrote:
>>> On Tue, Feb 25, 2014 at 12:28:04AM +0100, Alexander Graf wrote:
>>> Configuration of tunables and Linux virtual memory settings has traditio=
nally
>>> happened via sysctl. Thanks to that there are well established ways to m=
ake
>>> sysctl configuration bits persistent (sysctl.conf).
>>>=20
>>> KSM introduced a sysfs based configuration path which is not covered by u=
ser
>>> space persistent configuration frameworks.
>>>=20
>>> In order to make life easy for sysadmins, this patch adds all access to a=
ll
>>> KSM tunables via sysctl as well. That way sysctl.conf works for KSM as w=
ell,
>>> giving us a streamlined way to make KSM configuration persistent.
>>=20
>> ksm can be a module, so this won't work.
>=20
> That's news to me.  Are you writing of some Red Hat patches, or just
> misled by the "module_init(ksm_init)" which used the last line of ksm.c?

Ugh, sorry. I should have double-checked this. KSM is bool in Kconfig and so=
 is THP.

>=20
> I don't mind Alex's patch, but I do think the same should be done for
> THP as for KSM, and a general

I agree.

> solution more attractive than more #ifdefs
> one by one.  Should a general

I don't see a good alternative to this.

> solution just be in userspace, in sysctl(8)?

User space needs to have the ability to list available sysctls, so we need t=
o have an enumerable map between sys and sysctl somewhere. Keeping that list=
 close to where the actual files are implemented seems to make sense to me, a=
s it's very hard to miss out on addition and removal of parameters throughou=
t the stack this way. That's why I put it here.


Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
