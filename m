Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id 1342182F64
	for <linux-mm@kvack.org>; Wed, 28 Oct 2015 13:10:52 -0400 (EDT)
Received: by obbza9 with SMTP id za9so11830818obb.1
        for <linux-mm@kvack.org>; Wed, 28 Oct 2015 10:10:51 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id ol4si14710436obc.61.2015.10.28.10.10.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Oct 2015 10:10:51 -0700 (PDT)
Subject: Re: [PATCH v11 15/15] HMM: add documentation explaining HMM internals
 and how to use it.
References: <1445461210-2605-1-git-send-email-jglisse@redhat.com>
 <1445461210-2605-16-git-send-email-jglisse@redhat.com>
 <562856BD.3020806@infradead.org> <1445995167.3405.165.camel@infradead.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <56310188.2020308@infradead.org>
Date: Wed, 28 Oct 2015 10:10:32 -0700
MIME-Version: 1.0
In-Reply-To: <1445995167.3405.165.camel@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Woodhouse <dwmw2@infradead.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>

On 10/27/15 18:19, David Woodhouse wrote:
> On Wed, 2015-10-21 at 20:23 -0700, Randy Dunlap wrote:
>> On 10/21/15 14:00, JA?A(C)rA?A'me Glisse wrote:
> ...
>>> Signed-off-by: JA?A(C)rA?A'me Glisse <jglisse@redhat.com>
> 
> Not sure how Randy's email screwed that one up; it was a perfectly fine
> instance of your name.
> 

I'm probably missing some config setting in Thunderbird.


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
