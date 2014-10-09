Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 3CC516B0038
	for <linux-mm@kvack.org>; Thu,  9 Oct 2014 15:14:41 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id rd3so285308pab.6
        for <linux-mm@kvack.org>; Thu, 09 Oct 2014 12:14:40 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id ub8si1682950pac.5.2014.10.09.12.14.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 09 Oct 2014 12:14:39 -0700 (PDT)
Message-ID: <5436DDEB.5090004@oracle.com>
Date: Thu, 09 Oct 2014 15:11:39 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] mm: poison critical mm/ structs
References: <1412041639-23617-1-git-send-email-sasha.levin@oracle.com> <20141001140725.fd7f1d0cf933fbc2aa9fc1b1@linux-foundation.org> <542C749B.1040103@oracle.com> <alpine.LSU.2.11.1410020154500.6444@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1410020154500.6444@eggly.anvils>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mgorman@suse.de

On 10/02/2014 05:23 AM, Hugh Dickins wrote:
> I'm glad to hear they've confirmed some vm_area_struct corruption:
> any ideas on where that's coming from?

Hugh,

I think that what we're seeing isn't a corruption of vm_area_struct
per-se, but something weirder.

I've poisoned every spot where vm_area_struct is allocated, and yet
there seems to be nothing that's hitting that field before we end
up using a "zeroed out" vm_area_struct.

The results are the same both with and without kasan, there seems
to be no corruption happening anywhere, but we somehow end up with
an empty vm_area_struct.

It also somewhat makes sense considering that we're seeing no slub
corruption either. Either something is zeroing out *exactly*
vm_area_struct, or it's not really corruption...


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
