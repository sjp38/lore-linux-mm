Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id A4D1F6B0062
	for <linux-mm@kvack.org>; Tue, 18 Dec 2012 15:18:16 -0500 (EST)
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: [RFC 0/2] auto-ballooning prototype (guest part)
Date: Tue, 18 Dec 2012 18:17:28 -0200
Message-Id: <1355861850-2702-1-git-send-email-lcapitulino@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, riel@redhat.com, aquini@redhat.com, mst@redhat.com, amit.shah@redhat.com, agl@us.ibm.com

Hi,

This series implements an early protoype of a new feature called
automatic ballooning. This is based on ideas by Rik van Riel and
I also got some help from Rafael Aquini (misconceptions and bugs
are all mine, though).

The auto-ballooning feature automatically performs balloon inflate
and deflate based on host and guest memory pressure. This can help
to avoid swapping or worse in both, host and guest.

This series implements the guest part. Full details on the design
and implementation can be found in patch 2/2.

To test this you will also need the host part, which can be found
here (please, never mind the repo name):

 git://repo.or.cz/qemu/qmp-unstable.git balloon/auto-ballooning/rfc

Any feedback is appreciated!

Luiz Capitulino (2):
  virtio_balloon: move locking to the balloon thread
  virtio_balloon: add auto-ballooning support

 drivers/virtio/virtio_balloon.c     | 60 ++++++++++++++++++++++++++++++++++---
 include/uapi/linux/virtio_balloon.h |  1 +
 2 files changed, 57 insertions(+), 4 deletions(-)

-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
