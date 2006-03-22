Message-ID: <4421D7D5.6010809@garzik.org>
Date: Wed, 22 Mar 2006 18:03:49 -0500
From: Jeff Garzik <jeff@garzik.org>
MIME-Version: 1.0
Subject: Re: [PATCH 02/34] mm: page-replace-kconfig-makefile.patch
References: <20060322223107.12658.14997.sendpatchset@twins.localnet> <20060322223128.12658.81399.sendpatchset@twins.localnet>
In-Reply-To: <20060322223128.12658.81399.sendpatchset@twins.localnet>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Bob Picco <bob.picco@hp.com>, Andrew Morton <akpm@osdl.org>, IWAMOTO Toshihiro <iwamoto@valinux.co.jp>, Christoph Lameter <christoph@lameter.com>, Wu Fengguang <wfg@mail.ustc.edu.cn>, Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@osdl.org>, Rik van Riel <riel@redhat.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:
> From: Peter Zijlstra <a.p.zijlstra@chello.nl>
> 
> Introduce the configuration option, and modify the Makefile.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Signed-off-by: Marcelo Tosatti <marcelo.tosatti@cyclades.com>

For future patch posting, -please- use a sane email subject.

The email subject is used as a one-line summary for each changeset. 
While "page-replace-kconfig-makefile.patch" certainly communicates 
information, its much less easy to read than normal.  It also makes the 
git changelog summary (git log $branch..$branch2 | git shortlog) that 
Linus posts much uglier:

Peter Zijlstra:
	[PATCH] mm: kill-page-activate.patch
	[PATCH] mm: page-replace-kconfig-makefile.patch
	[PATCH] mm: page-replace-insert.patch
	[PATCH] mm: page-replace-use_once.patch

See http://linux.yyz.us/patch-format.html for more info.

Regards,

	Jeff


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
