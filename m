Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id D9C0B6B002D
	for <linux-mm@kvack.org>; Sat,  5 Nov 2011 10:38:22 -0400 (EDT)
Received: by wyg24 with SMTP id 24so4314849wyg.14
        for <linux-mm@kvack.org>; Sat, 05 Nov 2011 07:38:20 -0700 (PDT)
Message-ID: <1320503897.2428.8.camel@discretia>
Subject: [PATCH] mm: migrate: One less atomic operation
From: Jacobo Giralt <jacobo.giralt@gmail.com>
Date: Sat, 05 Nov 2011 15:38:17 +0100
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, mgorman@suse.de, minchan.kim@gmail.com, hughd@google.com, hannes@cmpxchg.org, npiggin@suse.de

