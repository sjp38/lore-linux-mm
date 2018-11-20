Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1B9706B1FCB
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 08:43:37 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id b7so1289938eda.10
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 05:43:37 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i53-v6sor21843408ede.8.2018.11.20.05.43.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Nov 2018 05:43:35 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 0/3] few memory offlining enhancements
Date: Tue, 20 Nov 2018 14:43:20 +0100
Message-Id: <20181120134323.13007-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <OSalvador@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Hildenbrand <david@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@suse.com>

I have been chasing memory offlining not making progress recently. On
the way I have noticed few weird decisions in the code. The migration
itself is restricted without a reasonable justification and the retry
loop around the migration is quite messy. This is addressed by patch 1
and patch 2.

Patch 3 is targeting on the faultaround code which has been a hot
candidate for the initial issue reported upstream [1] and that I am
debugging internally. It turned out to be not the main contributor
in the end but I believe we should address it regardless. See the patch
description for more details.

[1] http://lkml.kernel.org/r/20181114070909.GB2653@MiWiFi-R3L-srv
