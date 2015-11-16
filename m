Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id A31136B0253
	for <linux-mm@kvack.org>; Sun, 15 Nov 2015 20:38:34 -0500 (EST)
Received: by pacej9 with SMTP id ej9so50645207pac.2
        for <linux-mm@kvack.org>; Sun, 15 Nov 2015 17:38:34 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id jw6si46794715pbc.214.2015.11.15.17.38.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 Nov 2015 17:38:34 -0800 (PST)
Received: by pacej9 with SMTP id ej9so50644994pac.2
        for <linux-mm@kvack.org>; Sun, 15 Nov 2015 17:38:33 -0800 (PST)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.0 \(3094\))
Subject: Re: [PATCH] mm: change may_enter_fs check condition
From: yalin wang <yalin.wang2010@gmail.com>
In-Reply-To: <20151113153615.GE2632@dhcp22.suse.cz>
Date: Mon, 16 Nov 2015 09:38:32 +0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <77563C7C-973D-40CF-8AC3-FA550D349BE2@gmail.com>
References: <1447415255-832-1-git-send-email-yalin.wang2010@gmail.com> <5645D10C.701@suse.cz> <20151113153615.GE2632@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, vdavydov@parallels.com, hannes@cmpxchg.org, mgorman@techsingularity.net, tj@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


> On Nov 13, 2015, at 23:36, Michal Hocko <mhocko@kernel.org> wrote:
>=20
> On Fri 13-11-15 13:01:16, Vlastimil Babka wrote:
>> On 11/13/2015 12:47 PM, yalin wang wrote:
>>> Add page_is_file_cache() for __GFP_FS check,
>>> otherwise, a Pageswapcache() && PageDirty() page can always be write
>>> back if the gfp flag is __GFP_FS, this is not the expected behavior.
>>=20
>> I'm not sure I understand your point correctly *), but you seem to =
imply
>> that there would be an allocation that has __GFP_FS but doesn't have
>> __GFP_IO? Are there such allocations and does it make sense?
>=20
> No it doesn't. There is a natural layering here and __GFP_FS =
allocations
> should contain __GFP_IO.
>=20
> The patch as is makes only little sense to me. Are you seeing any =
issue
> which this is trying to fix?
mm..
i don=E2=80=99t see issue for this part ,
just feel confuse when i see code about this part ,
then i make a patch for this .
i am not sure if __GFP_FS will make sure __GFP_IO flag must be always =
set.
if it is ,  i think can add comment here to make people clear . :)

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
