Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 7CC816201FE
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 06:21:51 -0400 (EDT)
Date: Tue, 13 Jul 2010 06:21:33 -0400
From: Xiaotian Feng <dfeng@redhat.com>
Message-Id: <20100713102132.2835.45692.sendpatchset@danny.redhat>
In-Reply-To: <20100713101650.2835.15245.sendpatchset@danny.redhat>
References: <20100713101650.2835.15245.sendpatchset@danny.redhat>
Subject: [PATCH -mmotm 25/30] nfs: disable data cache revalidation for swapfiles
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Cc: riel@redhat.com, cl@linux-foundation.org, a.p.zijlstra@chello.nl, Xiaotian Feng <dfeng@redhat.com>, linux-kernel@vger.kernel.org, lwang@redhat.com, penberg@cs.helsinki.fi, akpm@linux-foundation.org, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

