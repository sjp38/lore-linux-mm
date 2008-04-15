From: David Howells <dhowells@redhat.com>
In-Reply-To: <20080414221846.967753424@sgi.com>
References: <20080414221846.967753424@sgi.com> <20080414221808.269371488@sgi.com>
Subject: Re: [patch 11/19] frv: Use kbuild.h instead of defining macros in asm-offsets.c
Date: Tue, 15 Apr 2008 10:55:16 +0100
Message-ID: <15368.1208253316@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: dhowells@redhat.com, Andrew Morton <akpm@linux-foundation.org>, apw@shadowen.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

arch/frv/kernel/asm-offsets.c:10:26: error: linux/kbuild.h: No such file or directory

Is this something that's queued in the -mm tree?

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
