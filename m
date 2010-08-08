Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5260C6B02A4
	for <linux-mm@kvack.org>; Sun,  8 Aug 2010 08:43:42 -0400 (EDT)
Message-ID: <4C5EA651.7080009@kernel.org>
Date: Sun, 08 Aug 2010 14:42:57 +0200
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: [PATCH] percpu: fix a memory leak in pcpu_extend_area_map()
References: <1281261197-8816-1-git-send-email-shijie8@gmail.com>
In-Reply-To: <1281261197-8816-1-git-send-email-shijie8@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

