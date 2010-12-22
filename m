Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C0B2E6B0087
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 08:47:40 -0500 (EST)
From: KyongHo Cho <pullip.cho@samsung.com>
Subject: [PATCH] mm: simple approach to calculate combined index of adjacent buddy lists
Date: Wed, 22 Dec 2010 22:26:52 +0900
Message-Id: <1293024412-15617-1-git-send-email-pullip.cho@samsung.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: kgene.kim@samsung.com, Ilho Lee <ilho215.lee@samsung.com>, KyongHo Cho <pullip.cho@samsung.com>
List-ID: <linux-mm.kvack.org>

The previous approach of calucation of combined index was

page_idx & ~(1 << order))

but we have same result with

page_idx & buddy_idx
