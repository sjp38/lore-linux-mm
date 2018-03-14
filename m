Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 35CE16B000C
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 08:25:18 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id m198so1358903pga.4
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 05:25:18 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a89si1451481pfg.137.2018.03.14.05.25.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Mar 2018 05:25:17 -0700 (PDT)
Date: Wed, 14 Mar 2018 05:25:12 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 6/8] Pmalloc selftest
Message-ID: <20180314122512.GF29631@bombadil.infradead.org>
References: <20180313214554.28521-1-igor.stoppa@huawei.com>
 <20180313214554.28521-7-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180313214554.28521-7-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: david@fromorbit.com, rppt@linux.vnet.ibm.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Tue, Mar 13, 2018 at 11:45:52PM +0200, Igor Stoppa wrote:
> Add basic self-test functionality for pmalloc.

Here're some additional tests for your test-suite:

	for (i = 1; i; i *= 2)
		pzalloc(pool, i - 1, GFP_KERNEL);
