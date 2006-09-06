Message-Id: <20060906131630.793619000@chello.nl>>
Date: Wed, 06 Sep 2006 15:16:30 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 00/21] vm deadlock avoidance for NBD, NFS and iSCSI (take 6)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Cc: Daniel Phillips <phillips@google.com>, Rik van Riel <riel@redhat.com>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

--

The latest version of my networked swap patches.

These patches provide robust swap over NFS and iSCSI, and in lesser form
also over NBD (NBD cannot reconnect on network failure).

The following test scenario was used (for NFS and iSCSI):
 - client A mounts swap device on server B
 - client A starts heavy swapper
 - server B stops service
 - server B floods server A
 - server A is wedged;
    soft lockup detection messages are given
    sysrq-m shows free < min
 - server B resumes service
 - client A is seen to recover.

The iSCSI work depends on their upstream (svn) development work and requires
some additional user-space patches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
