Return-Path: <SRS0=7uET=XD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95FB3C433EF
	for <linux-mm@archiver.kernel.org>; Sun,  8 Sep 2019 12:47:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 36F6A218AC
	for <linux-mm@archiver.kernel.org>; Sun,  8 Sep 2019 12:47:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 36F6A218AC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 752A76B0005; Sun,  8 Sep 2019 08:47:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7019C6B0006; Sun,  8 Sep 2019 08:47:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5EFD06B0007; Sun,  8 Sep 2019 08:47:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0023.hostedemail.com [216.40.44.23])
	by kanga.kvack.org (Postfix) with ESMTP id 3F4CB6B0005
	for <linux-mm@kvack.org>; Sun,  8 Sep 2019 08:47:14 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id E57A06117
	for <linux-mm@kvack.org>; Sun,  8 Sep 2019 12:47:13 +0000 (UTC)
X-FDA: 75911728746.11.son94_7942026d2e15d
X-HE-Tag: son94_7942026d2e15d
X-Filterd-Recvd-Size: 11096
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf10.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun,  8 Sep 2019 12:47:13 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 390E1B048;
	Sun,  8 Sep 2019 12:47:11 +0000 (UTC)
Subject: Re: [patch for-5.3 0/4] revert immediate fallback to remote hugepages
To: David Rientjes <rientjes@google.com>,
 Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
 Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>,
 Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill@shutemov.name>,
 Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
 Linux-MM <linux-mm@kvack.org>
References: <alpine.DEB.2.21.1909041252230.94813@chino.kir.corp.google.com>
 <CAHk-=wjmF_MGe5sBDmQB1WGpr+QFWkqboHpL37JYB5WgnG8nMA@mail.gmail.com>
 <alpine.DEB.2.21.1909051345030.217933@chino.kir.corp.google.com>
 <alpine.DEB.2.21.1909071249180.81471@chino.kir.corp.google.com>
 <CAHk-=wifuQ68e6Q4F2txGS48WgcoX2REE4te5_j36ypV-T2ZKw@mail.gmail.com>
 <alpine.DEB.2.21.1909071829440.200558@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <d76f8cc3-97aa-8da5-408d-397467ea768b@suse.cz>
Date: Sun, 8 Sep 2019 14:47:08 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1909071829440.200558@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/8/19 3:50 AM, David Rientjes wrote:
> On Sat, 7 Sep 2019, Linus Torvalds wrote:
>=20
>>> Andrea acknowledges the swap storm that he reported would be fixed wi=
th
>>> the last two patches in this series
>>
>> The problem is that even you aren't arguing that those patches should
>> go into 5.3.
>>
>=20
> For three reasons: (a) we lack a test result from Andrea,

That's argument against the rfc patches 3+4s, no? But not for including
the reverts of reverts of reverts (patches 1+2).

> (b) there's=20
> on-going discussion, particularly based on Vlastimil's feedback, and=20

I doubt this will be finished and tested with reasonable confidence even
for the 5.4 merge window.

> (c) the patches will be refreshed incorporating that feedback as well a=
s=20
> Mike's suggestion to exempt __GFP_RETRY_MAYFAIL for hugetlb.

There might be other unexpected consequences (even if hugetlb wasn't
such an issue as I suspected, in the end).

>> So those fixes aren't going in, so "the swap storms would be fixed"
>> argument isn't actually an argument at all as far as 5.3 is concerned.
>>
>=20
> It indicates that progress has been made to address the actual bug with=
out=20
> introducing long-lived access latency regressions for others, particula=
rly=20
> those who use MADV_HUGEPAGE.  In the worst case, some systems running=20
> 5.3-rc4 and 5.3-rc5 have the same amount of memory backed by hugepages =
but=20
> on 5.3-rc5 the vast majority of it is allocated remotely.  This incurs =
a

It's been said before, but such sensitive code generally relies on
mempolicies or node reclaim mode, not THP __GFP_THISNODE implementation
details. Or if you know there's enough free memory and just needs to be
compacted, you could do it once via sysfs before starting up your workloa=
d.

> signficant performance regression regardless of platform; the only thin=
g=20
> needed to induce this is a fragmented local node that would otherwise b=
e=20
> compacted in 5.3-rc4 rather than quickly allocate remote on 5.3-rc5.
>=20
>> End result: we'd have the qemu-kvm instance performance problem in 5.3
>> that apparently causes distros to apply those patches that you want to
>> revert anyway.
>>
>> So reverting would just make distros not use 5.3 in that form.
>>
>=20
> I'm arguing to revert 5.3 back to the behavior that we have had for yea=
rs=20
> and actually fix the bug that everybody else seems to be ignoring and t=
hen=20
> *backport* those fixes to 5.3 stable and every other stable tree that c=
an=20
> use them.  Introducing a new mempolicy for NUMA locality into 5.3.0 tha=
t

I think it's rather removing the problematic implicit mempolicy of
__GFP_THISNODE.

> will subsequently changed in future 5.3 stable kernels and differs from=
=20
> all kernels from the past few years is not in anybody's best interest i=
f=20
> the actual problem can be fixed.  It requires more feedback than a=20
> one-line "the swap storms would be fixed with this."  That collaboratio=
n=20
> takes time and isn't something that should be rushed into 5.3-rc5.
>=20
> Yes, we can fix NUMA locality of hugepages when a workload like qemu is=
=20
> larger than a single socket; the vast majority of workloads in the=20
> datacenter are small than a socket and *cannot* incur the performance=20
> penalty if local memory is fragmented that 5.3-rc5 introduces.
>=20
> In other words, 5.3-rc5 is only fixing a highly specialized usecase whe=
re=20
> remote allocation is acceptable because the workload is larger than a=20
> socket *and* remote memory is not low on memory or fragmented.  If you

Clearly we disagree here which is the highly specialized usecase that
might get slower remote memory access, and which is more common workload
that will suffer from swap storms. No point arguing it further, but
several distros made the choice by carrying Andrea's patches already.

> consider the opposite of that, workloads smaller than a socket or local=
=20
> compaction actually works, this has introduced a measurable regression =
for=20
> everybody else.
>=20
> I'm not sure why we are ignoring a painfully obvious bug in the page=20
> allocator because of a poor feedback loop between itself and memory=20
> compaction and rather papering over it by falling back to remote memory=
=20
> when NUMA actually does matter.  If you release 5.3 without the first t=
wo=20
> patches in this series, I wouldn't expect any additional feedback or te=
st=20
> results to fix this bug considering all we have gotten so far is "this=20
> would fix this swap storms" and not collaborating to fix the issue for=20
> everybody rather than only caring about their own workloads.  At least =
my=20
> patches acknowledge and try to fix the issue the other is encountering.

I might have missed something, but you were asked for a reproducer of
your use case so others can develop patches with it in mind? Mel did
provide a simple example that shows the swap storms very easily.

