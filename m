Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 7CE516B0009
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 12:17:55 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id p63so34288384wmp.1
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 09:17:55 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id ay10si16461280wjc.212.2016.01.28.09.17.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jan 2016 09:17:54 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id 128so2855358wmz.3
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 09:17:54 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/2] vmstat updates
Date: Thu, 28 Jan 2016 18:17:44 +0100
Message-Id: <1454001466-27398-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Cristopher Lameter <clameter@sgi.com>, Mike Galbraith <mgalbraith@suse.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi Andrew,
the following two patches are on top of the current mmotm tree and the
first one is a fixup for 0eb77e988032 ("vmstat: make vmstat_updater
deferrable again and shut down on idle") merged during this merge
window.  Mike has encountered issues [1] and the first patch fixes both
issues.  The second patch is a follow up enhancement on top. I guess it
would be better to push this to 4.5 after it warms up in linux-next for
1-2 rc cycles to catch potential fallouts.

[1] http://lkml.kernel.org/r/1453566115.3529.8.camel@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
