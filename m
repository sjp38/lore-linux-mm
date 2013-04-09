Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 09CDC6B0006
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 18:19:07 -0400 (EDT)
Date: Tue, 9 Apr 2013 15:19:06 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v8 3/3] mm: reinititalise user and admin reserves if
 memory is added or removed
Message-Id: <20130409151906.2ee55116ca9e3abd80a90e3e@linux-foundation.org>
In-Reply-To: <20130408210039.GA3396@localhost.localdomain>
References: <20130408190738.GC2321@localhost.localdomain>
	<20130408133712.bd327017dec19a2c14e22662@linux-foundation.org>
	<20130408210039.GA3396@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Shewmaker <agshew@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, alan@lxorguk.ukuu.org.uk, simon.jeons@gmail.com, ric.masonn@gmail.com

On Mon, 8 Apr 2013 17:00:40 -0400 Andrew Shewmaker <agshew@gmail.com> wrote:

> Should I add the memory notifier code to mm/nommu.c too?
> I'm guessing that if a system doesn't have an mmu that it also 
> won't be hotplugging memory.

I doubt if we need to worry about memory hotplug on nommu machines,
so just do the minimum which is required to get nommu to compile
and link.  That's probably "nothing".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
