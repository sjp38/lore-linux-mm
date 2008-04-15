Date: Tue, 15 Apr 2008 12:09:27 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 11/19] frv: Use kbuild.h instead of defining macros in
 asm-offsets.c
In-Reply-To: <15368.1208253316@redhat.com>
Message-ID: <Pine.LNX.4.64.0804151209140.1500@schroedinger.engr.sgi.com>
References: <20080414221846.967753424@sgi.com> <20080414221808.269371488@sgi.com>
 <15368.1208253316@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, apw@shadowen.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 15 Apr 2008, David Howells wrote:

> arch/frv/kernel/asm-offsets.c:10:26: error: linux/kbuild.h: No such file or directory
> 
> Is this something that's queued in the -mm tree?

It hopefully will be queued soon.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
