Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 74BE26B0005
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 22:57:26 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id td3so1792406pab.2
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 19:57:26 -0800 (PST)
Received: from out21.biz.mail.alibaba.com (out21.biz.mail.alibaba.com. [205.204.114.132])
        by mx.google.com with ESMTP id t13si9252142pas.225.2016.03.08.19.57.24
        for <linux-mm@kvack.org>;
        Tue, 08 Mar 2016 19:57:25 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20160307160838.GB5028@dhcp22.suse.cz> <1457444565-10524-1-git-send-email-mhocko@kernel.org> <1457444565-10524-3-git-send-email-mhocko@kernel.org>
In-Reply-To: <1457444565-10524-3-git-send-email-mhocko@kernel.org>
Subject: Re: [PATCH 2/3] mm, compaction: cover all compaction mode in compact_zone
Date: Wed, 09 Mar 2016 11:57:00 +0800
Message-ID: <059f01d179b7$bc811fd0$35835f70$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: 'Hugh Dickins' <hughd@google.com>, 'Sergey Senozhatsky' <sergey.senozhatsky.work@gmail.com>, 'Vlastimil Babka' <vbabka@suse.cz>, 'Linus Torvalds' <torvalds@linux-foundation.org>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Mel Gorman' <mgorman@suse.de>, 'David Rientjes' <rientjes@google.com>, 'Tetsuo Handa' <penguin-kernel@I-love.SAKURA.ne.jp>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, 'Joonsoo Kim' <js1304@gmail.com>, linux-mm@kvack.org, 'LKML' <linux-kernel@vger.kernel.org>, 'Michal Hocko' <mhocko@suse.com>

>=20
> From: Michal Hocko <mhocko@suse.com>
>=20
> the compiler is complaining after "mm, compaction: change COMPACT_
> constants into enum"
>=20
> mm/compaction.c: In function =E2=80=98compact_zone=E2=80=99:
> mm/compaction.c:1350:2: warning: enumeration value =
=E2=80=98COMPACT_DEFERRED=E2=80=99 not handled in switch [-Wswitch]
>   switch (ret) {
>   ^
> mm/compaction.c:1350:2: warning: enumeration value =
=E2=80=98COMPACT_COMPLETE=E2=80=99 not handled in switch [-Wswitch]
> mm/compaction.c:1350:2: warning: enumeration value =
=E2=80=98COMPACT_NO_SUITABLE_PAGE=E2=80=99 not handled in switch =
[-Wswitch]
> mm/compaction.c:1350:2: warning: enumeration value =
=E2=80=98COMPACT_NOT_SUITABLE_ZONE=E2=80=99 not handled in switch =
[-Wswitch]
> mm/compaction.c:1350:2: warning: enumeration value =
=E2=80=98COMPACT_CONTENDED=E2=80=99 not handled in switch [-Wswitch]
>=20
> compaction_suitable is allowed to return only COMPACT_PARTIAL,
> COMPACT_SKIPPED and COMPACT_CONTINUE so other cases are simply
> impossible. Put a VM_BUG_ON to catch an impossible return value.
>=20
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
