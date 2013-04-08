Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 3DA906B0006
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 16:57:41 -0400 (EDT)
Date: Mon, 8 Apr 2013 13:57:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v8 3/3] mm: reinititalise user and admin reserves if
 memory is added or removed
Message-Id: <20130408135739.a373580e624def371b542df5@linux-foundation.org>
In-Reply-To: <20130408190738.GC2321@localhost.localdomain>
References: <20130408190738.GC2321@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Shewmaker <agshew@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, alan@lxorguk.ukuu.org.uk, simon.jeons@gmail.com, ric.masonn@gmail.com

On Mon, 8 Apr 2013 15:07:38 -0400 Andrew Shewmaker <agshew@gmail.com> wrote:

> This patch alters the admin and user reserves of the previous patches 
> in this series when memory is added or removed.
> 
> If memory is added and the reserves have been eliminated or increased above
> the default max, then we'll trust the admin.
> 
> If memory is removed and there isn't enough free memory, then we
> need to reset the reserves.
> 
> Otherwise keep the reserve set by the admin.
> 
> The reserve reset code is the same as the reserve initialization code.
> 
> Does this sound reasonable to other people? I figured that hot removal
> with too large of memory in the reserves was the most important case 
> to get right.
> 
> I tested hot addition and removal by triggering it via sysfs. The reserves 
> shrunk when they were set high and memory was removed. They were reset 
> higher when memory was added again.

I have added your Signed-off-by: to my copy of this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
