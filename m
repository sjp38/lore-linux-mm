Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 26EFE6B02F0
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 20:28:15 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 11so8252621pge.4
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 17:28:15 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id o65si133150pga.54.2017.09.20.17.28.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Sep 2017 17:28:14 -0700 (PDT)
Subject: Re: [PATCH v6 03/11] mm, x86: Add support for eXclusive Page Frame
 Ownership (XPFO)
References: <20170907173609.22696-1-tycho@docker.com>
 <20170907173609.22696-4-tycho@docker.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <9ca0ef74-b409-2eae-07f8-9fd7d83989a5@intel.com>
Date: Wed, 20 Sep 2017 17:28:11 -0700
MIME-Version: 1.0
In-Reply-To: <20170907173609.22696-4-tycho@docker.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tycho Andersen <tycho@docker.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, x86@kernel.org

At a high level, does this approach keep an attacker from being able to
determine the address of data in the linear map, or does it keep them
from being able to *exploit* it?  Can you have a ret2dir attack if the
attacker doesn't know the address, for instance?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
