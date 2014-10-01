Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 82E3A6B0069
	for <linux-mm@kvack.org>; Wed,  1 Oct 2014 17:07:28 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id z10so829039pdj.12
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 14:07:28 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id wm3si2025588pab.16.2014.10.01.14.07.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Oct 2014 14:07:27 -0700 (PDT)
Date: Wed, 1 Oct 2014 14:07:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/5] mm: poison critical mm/ structs
Message-Id: <20141001140725.fd7f1d0cf933fbc2aa9fc1b1@linux-foundation.org>
In-Reply-To: <1412041639-23617-1-git-send-email-sasha.levin@oracle.com>
References: <1412041639-23617-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, mgorman@suse.de

On Mon, 29 Sep 2014 21:47:14 -0400 Sasha Levin <sasha.levin@oracle.com> wrote:

> Currently we're seeing a few issues which are unexplainable by looking at the
> data we see and are most likely caused by a memory corruption caused
> elsewhere.
> 
> This is wasting time for folks who are trying to figure out an issue provided
> a stack trace that can't really point out the real issue.
> 
> This patch introduces poisoning on struct page, vm_area_struct, and mm_struct,
> and places checks in busy paths to catch corruption early.
> 
> This series was tested, and it detects corruption in vm_area_struct. Right now
> I'm working on figuring out the source of the corruption, (which is a long
> standing bug) using KASan, but the current code is useful as it is.

Is this still useful if/when kasan is in place?

It looks fairly cheap - I wonder if it should simply fall under
CONFIG_DEBUG_VM rather than the new CONFIG_DEBUG_VM_POISON.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
