Subject: Re: [RFC]  free_area[]  bitmap elimination [0/3]
From: Nigel Cunningham <ncunningham@linuxmail.org>
Reply-To: ncunningham@linuxmail.org
In-Reply-To: <4126B3F9.90706@jp.fujitsu.com>
References: <4126B3F9.90706@jp.fujitsu.com>
Content-Type: text/plain
Message-Id: <1093081389.5379.55.camel@laptop.cunninghams>
Mime-Version: 1.0
Date: Sat, 21 Aug 2004 19:43:09 +1000
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linux Memory Management <linux-mm@kvack.org>, LHMS <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

Hi.

On Sat, 2004-08-21 at 12:31, Hiroyuki KAMEZAWA wrote:
> Hi
> 
> This patch removes bitmap from buddy allocator used in
> alloc_pages()/free_pages() in the kernel 2.6.8.1.

For what it's worth, I like the concept. Suspend 2 currently builds a
bitmap of free pages precisely because iterating through these lists is
slow. Getting the data directly from page structs will allow me to
remove some code.

Nigel
-- 
Nigel Cunningham
Christian Reformed Church of Tuggeranong
PO Box 1004, Tuggeranong, ACT 2901

Many today claim to be tolerant. But true tolerance can cope with others
being intolerant.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
