Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0396F6B0279
	for <linux-mm@kvack.org>; Fri,  7 Jul 2017 05:10:42 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 4so6460172wrc.15
        for <linux-mm@kvack.org>; Fri, 07 Jul 2017 02:10:41 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g15si2527434wmd.94.2017.07.07.02.10.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jul 2017 02:10:40 -0700 (PDT)
Subject: Patch "mm: fix classzone_idx underflow in shrink_zones()" has been added to the 4.4-stable tree
From: <gregkh@linuxfoundation.org>
Date: Fri, 07 Jul 2017 11:10:27 +0200
In-Reply-To: <cf25f1a5-5276-90ea-1eac-f2a2aceffaef@suse.cz>
Message-ID: <1499418627229186@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vbabka@suse.cz, gregkh@linuxfoundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mgorman@techsingularity.net, mhocko@kernel.org, mhocko@suse.com, mhocko@suse.cz, minchan@kernel.org, stable@vger.kernel.org
Cc: stable-commits@vger.kernel.org


This is a note to let you know that I've just added the patch titled

    mm: fix classzone_idx underflow in shrink_zones()

to the 4.4-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     mm-fix-classzone_idx-underflow-in-shrink_zones.patch
and it can be found in the queue-4.4 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.
