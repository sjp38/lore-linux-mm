From: Michal Hocko <miso@dhcp22.suse.cz>
Subject: [PATCH 0/2] man-pages: clarify MAP_LOCKED semantic
Date: Wed, 13 May 2015 16:38:10 +0200
Message-ID: <1431527892-2996-1-git-send-email-miso@dhcp22.suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Michael Kerrisk <mtk.manpages@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

Hi,
during the previous discussion http://marc.info/?l=linux-mm&m=143022313618001&w=2
it was made clear that making mmap(MAP_LOCKED) semantic really have
mlock() semantic is too dangerous. Even though we can try to reduce the
failure space the mmap man page should make it really clear about the
subtle distinctions between the two. This is what that first patch does.
The second patch is a small clarification for MAP_POPULATE based on
David Rientjes feedback.
