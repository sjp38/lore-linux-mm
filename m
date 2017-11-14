Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 24F286B0253
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 04:55:41 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id j23so10838705wra.13
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 01:55:41 -0800 (PST)
Received: from mout02.posteo.de (mout02.posteo.de. [185.67.36.66])
        by mx.google.com with ESMTPS id h207si6823152wme.37.2017.11.14.01.55.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Nov 2017 01:55:39 -0800 (PST)
Received: from submission (posteo.de [89.146.220.130])
	by mout02.posteo.de (Postfix) with ESMTPS id 7A3E520C7F
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 10:55:39 +0100 (CET)
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: quoted-printable
Date: Tue, 14 Nov 2017 10:55:35 +0100
From: Martin Kepplinger <martink@posteo.de>
Subject: Re: [PATCH] mm: replace FSF address with web source in license
 notices
In-Reply-To: <20171114094946.owfohzm5iplttdw6@dhcp22.suse.cz>
References: <20171114094438.28224-1-martink@posteo.de>
 <20171114094946.owfohzm5iplttdw6@dhcp22.suse.cz>
Message-ID: <21c380cbf6a51b6823a1707b0d16b25e@posteo.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: catalin.marinas@arm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Am 14.11.2017 10:49 schrieb Michal Hocko:
> On Tue 14-11-17 10:44:38, Martin Kepplinger wrote:
>> A few years ago the FSF moved and "59 Temple Place" is wrong. Having=20
>> this
>> still in our source files feels old and unmaintained.
>>=20
>> Let's take the license statement serious and not confuse users.
>>=20
>> As https://www.gnu.org/licenses/gpl-howto.html suggests, we replace=20
>> the
>> postal address with "<http://www.gnu.org/licenses/>" in the mm=20
>> directory.
>=20
> Why to change this now? Isn't there a general plan to move to SPDX?

Shouldn't a move to SPDX only be additions to what we currently have?=20
That's
at least what the "reuse" project suggests, see=20
https://reuse.software/practices/
with "Don=E2=80=99t remove existing headers, but only add to them."

thanks

                                        martin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
