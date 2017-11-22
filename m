Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9A2396B028D
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 08:20:17 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id d14so10127725wrg.15
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 05:20:17 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q7si3339928edl.231.2017.11.22.05.20.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Nov 2017 05:20:16 -0800 (PST)
Subject: Re: [RFC PATCH 0/2] mm: introduce MAP_FIXED_SAFE
References: <20171116101900.13621-1-mhocko@kernel.org>
 <20171116121438.6vegs4wiahod3byl@dhcp22.suse.cz>
 <b1848e34-7fcd-8ad8-6a6a-3be3dce3fda7@nvidia.com>
 <20171120090509.moagbwu7ug3y42gj@dhcp22.suse.cz>
 <9a02b37c-978a-48ef-0b22-b1e4cbb9a704@nvidia.com>
 <20171122131245.fpqtipwdxzuaj6gl@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a35c5d6e-b862-8165-04cb-55f76189ebb5@suse.cz>
Date: Wed, 22 Nov 2017 14:20:14 +0100
MIME-Version: 1.0
In-Reply-To: <20171122131245.fpqtipwdxzuaj6gl@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, John Hubbard <jhubbard@nvidia.com>
Cc: linux-api@vger.kernel.org, Khalid Aziz <khalid.aziz@oracle.com>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Abdul Haleem <abdhalee@linux.vnet.ibm.com>, Joel Stanley <joel@jms.id.au>, Kees Cook <keescook@chromium.org>

On 11/22/2017 02:12 PM, Michal Hocko wrote:
> I will be probably stubborn and go with a shorter name I have currently.
> I am not very fond-of-very-long-names.

The short synonym for the last word is "German"

SCNR :P

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
