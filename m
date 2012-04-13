Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id DB57A6B004D
	for <linux-mm@kvack.org>; Fri, 13 Apr 2012 09:52:08 -0400 (EDT)
Date: Fri, 13 Apr 2012 08:52:05 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/2] mm: fix NULL ptr dereference in move_pages
In-Reply-To: <1334321902-7143-2-git-send-email-levinsasha928@gmail.com>
Message-ID: <alpine.DEB.2.00.1204130851470.10789@router.home>
References: <1334321902-7143-1-git-send-email-levinsasha928@gmail.com> <1334321902-7143-2-git-send-email-levinsasha928@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: akpm@linux-foundation.org, hughd@google.com, dave@linux.vnet.ibm.com, ebiederm@xmission.com, davej@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 13 Apr 2012, Sasha Levin wrote:

> Commit 3268c63 ("mm: fix move/migrate_pages() race on task struct") has added
> an odd construct where 'mm' is checked for being NULL, and if it is, it would
> get dereferenced anyways by mput()ing it.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
