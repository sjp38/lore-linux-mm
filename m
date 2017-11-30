Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 43F596B0069
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 03:24:08 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id r88so4404326pfi.23
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 00:24:08 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 43si2729685plb.94.2017.11.30.00.24.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 30 Nov 2017 00:24:07 -0800 (PST)
Date: Thu, 30 Nov 2017 09:24:05 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH v2] mmap.2: document new MAP_FIXED_SAFE flag
Message-ID: <20171130082405.b77eknaiblgmpa4s@dhcp22.suse.cz>
References: <20171129144219.22867-1-mhocko@kernel.org>
 <20171129144524.23518-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171129144524.23518-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Kerrisk <mtk.manpages@gmail.com>
Cc: linux-api@vger.kernel.org, Khalid Aziz <khalid.aziz@oracle.com>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>

Updated version based on feedback from John.
---
