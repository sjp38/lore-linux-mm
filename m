Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 4DE136B02A4
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 06:17:23 -0400 (EDT)
Date: Tue, 13 Jul 2010 06:17:02 -0400
From: Xiaotian Feng <dfeng@redhat.com>
Message-Id: <20100713101702.2835.19139.sendpatchset@danny.redhat>
In-Reply-To: <20100713101650.2835.15245.sendpatchset@danny.redhat>
References: <20100713101650.2835.15245.sendpatchset@danny.redhat>
Subject: [PATCH -mmotm 01/30] mm: serialize access to min_free_kbytes
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Cc: riel@redhat.com, cl@linux-foundation.org, a.p.zijlstra@chello.nl, Xiaotian Feng <dfeng@redhat.com>, linux-kernel@vger.kernel.org, lwang@redhat.com, penberg@cs.helsinki.fi, akpm@linux-foundation.org, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

