Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E95536B004F
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 00:18:08 -0400 (EDT)
Date: Tue, 15 Sep 2009 21:18:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.32 -mm Blackfin patches
Message-Id: <20090915211810.d1b83015.akpm@linux-foundation.org>
In-Reply-To: <8bd0f97a0909152056h61bfc487g6b8631966c6d72be@mail.gmail.com>
References: <8bd0f97a0909152056h61bfc487g6b8631966c6d72be@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mike Frysinger <vapier.adi@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 15 Sep 2009 23:56:21 -0400 Mike Frysinger <vapier.adi@gmail.com> wrote:

> On Tue, Sep 15, 2009 at 19:15, Andrew Morton wrote:
> > blackfin-convert-to-use-arch_gettimeoffset.patch
> 
> i thought John was merging this via some sort of patch series, but i
> can pick it up in the Blackfin tree to make sure things are really
> sane

Sent.

> > blackfin-fix-read-buffer-overflow.patch
> 
> the latter patch i merged into my tree (and i thought that i followed
> up in the original posting about this)

Well, it isn't in linux-next so as far as I'm concerned I have the
only copy.  Should you be getting your tree into linux-next?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
