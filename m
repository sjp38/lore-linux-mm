Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C037D6201FE
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 06:18:07 -0400 (EDT)
Date: Tue, 13 Jul 2010 06:17:47 -0400
From: Xiaotian Feng <dfeng@redhat.com>
Message-Id: <20100713101747.2835.45722.sendpatchset@danny.redhat>
In-Reply-To: <20100713101650.2835.15245.sendpatchset@danny.redhat>
References: <20100713101650.2835.15245.sendpatchset@danny.redhat>
Subject: [PATCH -mmotm 05/30] mm: sl[au]b: add knowledge of reserve pages
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Cc: riel@redhat.com, cl@linux-foundation.org, a.p.zijlstra@chello.nl, Xiaotian Feng <dfeng@redhat.com>, linux-kernel@vger.kernel.org, lwang@redhat.com, penberg@cs.helsinki.fi, akpm@linux-foundation.org, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

