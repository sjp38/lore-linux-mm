Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id D6DD16B0033
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 05:21:56 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id v186so2642619wma.9
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 02:21:56 -0800 (PST)
Received: from mout02.posteo.de (mout02.posteo.de. [185.67.36.66])
        by mx.google.com with ESMTPS id q76si1432694wme.249.2017.11.14.02.21.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Nov 2017 02:21:55 -0800 (PST)
Received: from submission (posteo.de [89.146.220.130])
	by mout02.posteo.de (Postfix) with ESMTPS id 1230D20CF2
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 11:21:54 +0100 (CET)
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: quoted-printable
Date: Tue, 14 Nov 2017 11:21:49 +0100
From: Martin Kepplinger <martink@posteo.de>
Subject: Re: [PATCH] mm: replace FSF address with web source in license
 notices
In-Reply-To: <20171114100202.bbegvtz6jckuyzcm@dhcp22.suse.cz>
References: <20171114094438.28224-1-martink@posteo.de>
 <20171114094946.owfohzm5iplttdw6@dhcp22.suse.cz>
 <21c380cbf6a51b6823a1707b0d16b25e@posteo.de>
 <20171114100202.bbegvtz6jckuyzcm@dhcp22.suse.cz>
Message-ID: <969a24d542fbd98ec8badf64e9d1909c@posteo.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: catalin.marinas@arm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Am 14.11.2017 11:02 schrieb Michal Hocko:
> On Tue 14-11-17 10:55:35, Martin Kepplinger wrote:
>> Am 14.11.2017 10:49 schrieb Michal Hocko:
>> > On Tue 14-11-17 10:44:38, Martin Kepplinger wrote:
>> > > A few years ago the FSF moved and "59 Temple Place" is wrong. Having
>> > > this
>> > > still in our source files feels old and unmaintained.
>> > >
>> > > Let's take the license statement serious and not confuse users.
>> > >
>> > > As https://www.gnu.org/licenses/gpl-howto.html suggests, we replace
>> > > the
>> > > postal address with "<http://www.gnu.org/licenses/>" in the mm
>> > > directory.
>> >
>> > Why to change this now? Isn't there a general plan to move to SPDX?
>>=20
>> Shouldn't a move to SPDX only be additions to what we currently have?=20
>> That's
>> at least what the "reuse" project suggests, see
>> https://reuse.software/practices/
>> with "Don=E2=80=99t remove existing headers, but only add to them."
>=20
> I thought the primary motivation was to unify _all_ headers and get rid
> of all the duplication. (aside from files which do not have any license
> which is under discussion elsewhere).

I doubt that this can be fully accieved in the long run :) It'd be nice=20
of course in
some way.

But I also doubt that it'd be so easy to remove the permission=20
statements.
The FSF who's license we use suggest to have them, but others do too.
And as mentioned, "using SPDX" doesn't imply "not having permission
statements".

But I think that's off-topic actually. Moving to SPDX could still be=20
done in
any way whatsoever after this. This change fixes a *mistake* and can=20
reduce
confusion or even support license compliance, who knows :)

thanks
                                         martin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
