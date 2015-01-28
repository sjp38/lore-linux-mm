Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 866716B006E
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 09:44:07 -0500 (EST)
Received: by mail-wi0-f174.google.com with SMTP id n3so12429004wiv.1
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 06:44:07 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.187])
        by mx.google.com with ESMTPS id b12si4522387wic.11.2015.01.28.06.44.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Jan 2015 06:44:06 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] mm: export "high_memory" symbol on !MMU
Date: Wed, 28 Jan 2015 15:43:52 +0100
Message-ID: <2715923.qFZi90ffep@wuerfel>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kirill.shutemov@linux.intel.com, linux-mm@kvack.org, gerg@uclinux.org, linux-arm-kernel@lists.infradead.org

