Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C72616B02EB
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 20:04:38 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id x78so7121267pff.7
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 17:04:38 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id w12si97909pgo.419.2017.09.20.17.04.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Sep 2017 17:04:37 -0700 (PDT)
Subject: Re: [PATCH v6 03/11] mm, x86: Add support for eXclusive Page Frame
 Ownership (XPFO)
References: <20170907173609.22696-1-tycho@docker.com>
 <20170907173609.22696-4-tycho@docker.com>
 <302be94d-7e44-001d-286c-2b0cd6098f7b@huawei.com>
 <20170911145020.fat456njvyagcomu@docker>
 <57e95ad2-81d8-bf83-3e78-1313daa1bb80@canonical.com>
 <431e2567-7600-3186-1489-93b855c395bd@huawei.com>
 <20170912143636.avc3ponnervs43kj@docker>
 <20170912181303.aqjj5ri3mhscw63t@docker>
 <91923595-7f02-3be0-9c59-9c1fd20c82a8@intel.com>
 <20170921000210.drjiywtp4n75yovk@docker>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <21bcc50a-f333-fb43-adef-ed501fc6b127@intel.com>
Date: Wed, 20 Sep 2017 17:04:35 -0700
MIME-Version: 1.0
In-Reply-To: <20170921000210.drjiywtp4n75yovk@docker>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tycho Andersen <tycho@docker.com>
Cc: Yisheng Xie <xieyisheng1@huawei.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, x86@kernel.org

On 09/20/2017 05:02 PM, Tycho Andersen wrote:
> ...and makes it easier to pair tlb flushes with changing the
> protections. I guess we still need the for loop, because we need to
> set/unset the xpfo bits as necessary, but I'll switch it to a single
> set_kpte(). This also implies that the xpfo bits should all be the
> same on every page in the mapping, which I think is true.

FWIW, it's a bit bonkers to keep all this duplicate xpfo metadata for
compound pages.  You could probably get away with only keeping it for
the head page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
