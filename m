Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 51BA66B02AA
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 06:22:37 -0400 (EDT)
Date: Tue, 13 Jul 2010 06:22:18 -0400
From: Xiaotian Feng <dfeng@redhat.com>
Message-Id: <20100713102217.2835.75779.sendpatchset@danny.redhat>
In-Reply-To: <20100713101650.2835.15245.sendpatchset@danny.redhat>
References: <20100713101650.2835.15245.sendpatchset@danny.redhat>
Subject: [PATCH -mmotm 29/30] fix null pointer deref in swap_entry_free
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Cc: riel@redhat.com, cl@linux-foundation.org, a.p.zijlstra@chello.nl, Xiaotian Feng <dfeng@redhat.com>, linux-kernel@vger.kernel.org, lwang@redhat.com, penberg@cs.helsinki.fi, akpm@linux-foundation.org, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

