Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 168DD8E0095
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 09:36:51 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id v4so6861640edm.18
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 06:36:51 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p2-v6sor3750551ejr.31.2018.12.11.06.36.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Dec 2018 06:36:49 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/3] THP eligibility reporting via proc
Date: Tue, 11 Dec 2018 15:36:38 +0100
Message-Id: <20181211143641.3503-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-api@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@intel.com>, David Rientjes <rientjes@google.com>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.com>, Mike Rapoport <rppt@linux.ibm.com>, Vlastimil Babka <vbabka@suse.cz>

Hi,
I've posted this as an RFC [1] and there didn't seem to be any pushback
so I am posting it for inclusion. If there are any concerns, please
speak up.

Original cover:
This series of three patches aims at making THP eligibility reporting
much more robust and long term sustainable. The trigger for the change
is a regression report [2] and the long follow up discussion. In short
the specific application didn't have good API to query whether a particular
mapping can be backed by THP so it has used VMA flags to workaround that.
These flags represent a deep internal state of VMAs and as such they should
be used by userspace with a great deal of caution.

A similar has happened for [3] when users complained that VM_MIXEDMAP is
no longer set on DAX mappings. Again a lack of a proper API led to an
abuse.

The first patch in the series tries to emphasise that that the semantic
of flags might change and any application consuming those should be really
careful.

The remaining two patches provide a more suitable interface to address [2]
and provide a consistent API to query the THP status both for each VMA
and process wide as well.

[1] http://lkml.kernel.org/r/20181120103515.25280-1-mhocko@kernel.org
[2] http://lkml.kernel.org/r/http://lkml.kernel.org/r/alpine.DEB.2.21.1809241054050.224429@chino.kir.corp.google.com
[3] http://lkml.kernel.org/r/20181002100531.GC4135@quack2.suse.cz
