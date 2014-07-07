Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
	by kanga.kvack.org (Postfix) with ESMTP id 8BA65900002
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 14:52:21 -0400 (EDT)
Received: by mail-we0-f171.google.com with SMTP id q58so4900614wes.2
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 11:52:21 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id ni12si42441979wic.49.2014.07.07.11.52.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 07 Jul 2014 11:52:20 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 0/3] mm: memcontrol: rewrite uncharge API follow-up fixes
Date: Mon,  7 Jul 2014 14:52:10 -0400
Message-Id: <1404759133-29218-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Andrew,

here are 3 fixlets on top of the memcg uncharge rewrite, two of which
based on problems that Hugh reported.  They should apply directly on
top of the existing fixlets for "mm: memcontrol: rewrite uncharge API".

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
