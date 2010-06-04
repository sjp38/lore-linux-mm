Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A2E626B01B8
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 14:47:48 -0400 (EDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 0/2 RFC v3] Livelock avoidance for data integrity writeback
Date: Fri,  4 Jun 2010 20:47:09 +0200
Message-Id: <1275677231-15662-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, npiggin@suse.de, david@fromorbit.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


  Hi,

  I've revived my patches to implement livelock avoidance for data integrity
writes. Due to some concerns whether tagging of pages before writeout cannot
be too costly to use for WB_SYNC_NONE mode (where we stop after nr_to_write
pages) I've changed the patch to use page tagging only in WB_SYNC_ALL mode
where we are sure that we write out all the tagged pages. Later, we can think
about using tagging for livelock avoidance for WB_SYNC_NONE mode as well...
  As always comments are welcome.

                                                                        Honza

PS: I'm sorry for sending this twice. I've screwed up the list address in the
first posting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
