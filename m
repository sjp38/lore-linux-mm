Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 563466B0023
	for <linux-mm@kvack.org>; Fri,  6 May 2011 03:50:31 -0400 (EDT)
Date: Fri, 6 May 2011 09:50:27 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH v4] mm: make expand_downwards symmetrical to expand_upwards
Message-ID: <20110506075027.GB32495@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi Andrew,
I am sorry to repost this kind of trivial cleanup for the 4th time,
but after recent discussion (https://lkml.org/lkml/2011/5/3/323)
with Hugh I think that it makes sense to keep the original
expand_{upwards,downwards} without being explicit about the stack in the
name. As Hugh pointed out, IA64 uses expand_upwards for something that
is not really a stack (it is a backing storage for registers).
The following patch reworks the original one so it is not incremental.
If you prefer incremental one I can send that one instead. 
Just for record this patch obsoletes:
	mm-make-expand_downwards-symmetrical-with-expand_upwards.patch
	mm-make-expand_downwards-symmetrical-with-expand_upwards-v3.patch
in your current (2011-04-29-16-25) mm tree.

---
