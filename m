Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f177.google.com (mail-ve0-f177.google.com [209.85.128.177])
	by kanga.kvack.org (Postfix) with ESMTP id AC5FD6B0035
	for <linux-mm@kvack.org>; Fri, 30 May 2014 14:28:04 -0400 (EDT)
Received: by mail-ve0-f177.google.com with SMTP id db11so2541378veb.8
        for <linux-mm@kvack.org>; Fri, 30 May 2014 11:28:04 -0700 (PDT)
Received: from qmta15.emeryville.ca.mail.comcast.net (qmta15.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:228])
        by mx.google.com with ESMTP id de1si3729068vdd.33.2014.05.30.11.28.03
        for <linux-mm@kvack.org>;
        Fri, 30 May 2014 11:28:03 -0700 (PDT)
Message-Id: <20140530182753.191965442@linux.com>
Date: Fri, 30 May 2014 13:27:53 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [PATCH 0/4] slab: common kmem_cache_cpu functions V1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>

The patchset provides two new functions in mm/slab.h and modifies SLAB and SLUB to use these.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
