Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2A1946B028E
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 10:55:46 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id y71so105023435pgd.0
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 07:55:46 -0800 (PST)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id q4si27034928pgc.52.2016.11.15.07.55.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 07:55:45 -0800 (PST)
Received: by mail-pg0-x241.google.com with SMTP id p66so12161049pga.2
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 07:55:45 -0800 (PST)
Date: Tue, 15 Nov 2016 16:55:38 +0100
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH 0/3] z3fold: per-page spinlock and other smaller
 optimizations
Message-Id: <20161115165538.878698352bd45e212751b57a@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>

Coming is the patchset with the per-page spinlock as the main
modification, and two smaller dependent patches, one of which
removes build error when the z3fold header size exceeds the
size of a chunk, and the other puts non-compacted pages to the
end of the unbuddied list.

Signed-off-by: Vitaly Wool <vitalywool@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
