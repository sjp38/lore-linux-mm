From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Fri, 25 Aug 2006 17:39:46 +0200
Message-Id: <20060825153946.24271.42758.sendpatchset@twins>
Subject: [PATCH 0/4] VM deadlock prevention -v5
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Cc: Indan Zupancic <indan@nul.nu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Evgeniy Polyakov <johnpol@2ka.mipt.ru>, Daniel Phillips <phillips@google.com>, Rik van Riel <riel@redhat.com>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

Hi,

The latest version of the VM deadlock prevention work.

The basic premises is that network sockets serving the VM need undisturbed
functionality in the face of severe memory shortage.

This patch-set provides the framework to provide this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
