Date: Tue, 23 Jan 2001 12:38:42 -0600
From: Timur Tabi <ttabi@interactivesi.com>
In-Reply-To: <Pine.GSO.4.10.10101231903380.14027-100000@zeus.fh-brandenburg.de>
References: <3A6D5D28.C132D416@sangate.com>
Subject: Re: ioremap_nocache problem?
Message-Id: <20010123183603Z131186-221+36@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

** Reply to message from Roman Zippel <zippel@fh-brandenburg.de> on Tue, 23 Jan
2001 19:12:36 +0100 (MET)


> ioremap creates a new mapping that shouldn't interfere with MTRR, whereas
> you can map a MTRR mapped area into userspace. But I'm not sure if it's
> correct that no flag is set for boot_cpu_data.x86 <= 3...

I was under the impression that the "don't cache" bit that ioremap_nocache sets
overrides any MTRR.


-- 
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please direct the reply to the mailing list only.  Don't send another copy to me.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
