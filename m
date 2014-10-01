Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 138786B0038
	for <linux-mm@kvack.org>; Wed,  1 Oct 2014 17:48:37 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id rd3so990618pab.6
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 14:48:36 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id gm1si2108744pbd.6.2014.10.01.14.48.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Oct 2014 14:48:35 -0700 (PDT)
Date: Wed, 1 Oct 2014 14:48:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/5] mm: poison critical mm/ structs
Message-Id: <20141001144834.ff3ff0349951df734d159fb3@linux-foundation.org>
In-Reply-To: <542C749B.1040103@oracle.com>
References: <1412041639-23617-1-git-send-email-sasha.levin@oracle.com>
	<20141001140725.fd7f1d0cf933fbc2aa9fc1b1@linux-foundation.org>
	<542C749B.1040103@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, mgorman@suse.de

On Wed, 01 Oct 2014 17:39:39 -0400 Sasha Levin <sasha.levin@oracle.com> wrote:

> > It looks fairly cheap - I wonder if it should simply fall under
> > CONFIG_DEBUG_VM rather than the new CONFIG_DEBUG_VM_POISON.
> 
> Config options are cheap as well :)

Thing is, lots of people are enabling CONFIG_DEBUG_VM, but a smaller
number of people will enable CONFIG_DEBUG_VM_POISON.  Less coverage. 

Defaulting to y if CONFIG_DEBUG_VM might help, but if people do `make
oldconfig' when CONFIG_DEBUG_VM=n, their CONFIG_DEBUG_VM_POISON will
get set to `n' and will remain that way when they set CONFIG_DEBUG_VM
again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
