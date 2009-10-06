Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 480146B004D
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 09:49:56 -0400 (EDT)
Subject: Re: [PATCH][RFC] add MAP_UNLOCKED mmap flag
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20091006121603.GK9832@redhat.com>
References: <20091006190938.126F.A69D9226@jp.fujitsu.com>
	 <20091006102136.GH9832@redhat.com>
	 <20091006192454.1272.A69D9226@jp.fujitsu.com>
	 <20091006103300.GI9832@redhat.com>
	 <2f11576a0910060510y401c1d5ax6f17135478d22899@mail.gmail.com>
	 <20091006121603.GK9832@redhat.com>
Content-Type: text/plain
Date: Tue, 06 Oct 2009 15:50:03 +0200
Message-Id: <1254837003.21044.283.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2009-10-06 at 14:16 +0200, Gleb Natapov wrote:
> > No, I only think your case doesn't fit MC_FUTURE.
> > I haven't find any real benefit in this patch.

> I did. It allows me to achieve something I can't now. Steps you provide
> just don't fit my needs. I need all memory areas (current and feature) to be
> locked except one. Very big one. You propose to lock memory at some
> arbitrary point and from that point on all newly mapped memory areas will
> be unlocked. Don't you see it is different?

While true, it does demonstrates very sloppy programming. The proper fix
is to rework qemu to mlock what is needed.

I'm not sure encouraging mlockall() usage is a good thing. When using
resource locks one had better know what he's doing. mlockall() doesn't
promote caution.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
