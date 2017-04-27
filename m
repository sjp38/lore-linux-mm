Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id A91FC6B0038
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 11:31:48 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id q71so8439977qkl.2
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 08:31:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b131si3149620qkc.139.2017.04.27.08.31.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Apr 2017 08:31:48 -0700 (PDT)
Date: Thu, 27 Apr 2017 11:31:40 -0400 (EDT)
From: Jerome Glisse <jglisse@redhat.com>
Message-ID: <1535585820.3659728.1493307100894.JavaMail.zimbra@redhat.com>
In-Reply-To: <20170427075652.GA4706@dhcp22.suse.cz>
References: <20170421120512.23960-1-mhocko@kernel.org> <20170427075652.GA4706@dhcp22.suse.cz>
Subject: Re: [PATCH -v3 0/13] mm: make movable onlining suck less
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Balbir Singh <bsingharora@gmail.com>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tobias Regnery <tobias.regnery@gmail.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

> Hi all,
> Andrew prefers to take this after the merge window so I will repost the
> full series then. Any feedback is still highly appreciated of course.

Andrew i will repost HMM too when Michal repost (unless there is no rebase
conflict but i doubt it).

Cheers,
J=C3=A9r=C3=B4me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
