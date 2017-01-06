Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0C4216B0267
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 15:54:43 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 17so867277479pfy.2
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 12:54:43 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id h63si56250336pge.12.2017.01.06.12.54.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jan 2017 12:54:42 -0800 (PST)
Subject: Re: [HMM v15 00/16] HMM (Heterogeneous Memory Management) v15
References: <1483721203-1678-1-git-send-email-jglisse@redhat.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <bfdbca34-8253-8294-400b-5ddf6e48ae37@intel.com>
Date: Fri, 6 Jan 2017 12:54:41 -0800
MIME-Version: 1.0
In-Reply-To: <1483721203-1678-1-git-send-email-jglisse@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>

On 01/06/2017 08:46 AM, JA(C)rA'me Glisse wrote:
> I think it is ready for next or at least i would like to know any
> reasons to not accept this patchset.

Do you have a real in-tree user for this yet?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
