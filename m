Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A52E96B0012
	for <linux-mm@kvack.org>; Tue,  3 May 2011 10:10:46 -0400 (EDT)
Date: Tue, 3 May 2011 16:10:44 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH resend] mm: get rid of CONFIG_STACK_GROWSUP || CONFIG_IA64
Message-ID: <20110503141044.GA25351@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi Andrew,
the patch bellow probably got lost in the huge "parisc crashes with slub"
thread triggered by my earlier clean up in this area so I am resending
it standalone.
---
