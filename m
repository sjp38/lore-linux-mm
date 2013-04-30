From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 0/5] mm: Ability to monitor task memory changes (v4)
Date: Tue, 30 Apr 2013 20:10:59 +0400
Message-ID: <517FED13.8090806@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Matt Mackall <mpm@selenic.com>, Marcelo Tosatti <mtosatti@redhat.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

This is the resend and (while the iron is hot) the request for merge of
the implementation of the soft-dirty bit concept that should help to track
changes in user memory.

This set differs from what Andrew has sent recently in a single point --
the way pagemap entries' bits are reused (patch #5, and one hunk about
Documantation/ file in patch #4). Other places hasn't changed at all.

Thanks,
Pavel
