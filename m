Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C5F3E8E004D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 09:27:51 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id e17so6962348edr.7
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 06:27:51 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n19-v6sor3779554ejr.12.2018.12.11.06.27.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Dec 2018 06:27:50 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/3] few memory offlining enhancements
Date: Tue, 11 Dec 2018 15:27:38 +0100
Message-Id: <20181211142741.2607-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, David Hildenbrand <david@redhat.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Oscar Salvador <osalvador@suse.de>, Pavel Tatashin <pasha.tatashin@soleen.com>, William Kucharski <william.kucharski@oracle.com>

This has been posted as an RFC [1]. There was a general agreement for
these patches. I hope I have addressed all the review feedback.

Original cover:
I have been chasing memory offlining not making progress recently. On
the way I have noticed few weird decisions in the code. The migration
itself is restricted without a reasonable justification and the retry
loop around the migration is quite messy. This is addressed by patch 1
and patch 2.

Patch 3 is targeting on the faultaround code which has been a hot
candidate for the initial issue reported upstream [2] and that I am
debugging internally. It turned out to be not the main contributor
in the end but I believe we should address it regardless. See the patch
description for more details.

[1] http://lkml.kernel.org/r/20181120134323.13007-1-mhocko@kernel.org
[2] http://lkml.kernel.org/r/20181114070909.GB2653@MiWiFi-R3L-srv
