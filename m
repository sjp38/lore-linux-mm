Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id E6CA26B0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 16:49:06 -0500 (EST)
Date: Thu, 21 Feb 2013 13:49:04 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 10/18] mm: teach truncate_inode_pages_range() to
 handle non page aligned ranges
Message-Id: <20130221134905.9a1e2c9e.akpm@linux-foundation.org>
In-Reply-To: <alpine.LFD.2.00.1302210929590.19354@localhost>
References: <1360055531-26309-1-git-send-email-lczerner@redhat.com>
	<1360055531-26309-11-git-send-email-lczerner@redhat.com>
	<20130207154042.92430aed.akpm@linux-foundation.org>
	<alpine.LFD.2.00.1302080948110.3225@localhost>
	<alpine.LFD.2.00.1302210929590.19354@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Luk=C3=A1=C5=A1?= Czerner <lczerner@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, Hugh Dickins <hughd@google.com>

On Thu, 21 Feb 2013 09:33:56 +0100 (CET)
Luk____ Czerner <lczerner@redhat.com> wrote:

> what's the status of the patch set ?

Forgotten about :(

> Can we get this in in this merge window ?

Please do a full resend after 3.9-rc1 and let's take it up again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
