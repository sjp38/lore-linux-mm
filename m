Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id 954B96B0035
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 07:28:52 -0400 (EDT)
Received: by mail-la0-f44.google.com with SMTP id q1so8548496lam.3
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 04:28:51 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jt8si18265549lbc.28.2014.09.23.04.28.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 23 Sep 2014 04:28:50 -0700 (PDT)
Date: Tue, 23 Sep 2014 13:28:48 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] mm, debug: mm-introduce-vm_bug_on_mm-fix-fix.patch
Message-ID: <20140923112848.GA10046@dhcp22.suse.cz>
References: <5420b8b0.9HdYLyyuTikszzH8%akpm@linux-foundation.org>
 <1411464279-20158-1-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1411464279-20158-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, Sasha Levin <sasha.levin@oracle.com>

And there is another one hitting during randconfig. The patch makes my
eyes bleed but I don't know about other way without breaking out the
thing into separate parts sounds worse because we can mix with other
messages then.
---
