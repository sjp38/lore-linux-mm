Subject: RE: [Suspend2-devel] How to reduce page cache?
From: Nigel Cunningham <ncunningham@cyclades.com>
Reply-To: ncunningham@cyclades.com
In-Reply-To: <000001c5251e$f52ab2f0$59f22e93@PC>
References: <000001c5251e$f52ab2f0$59f22e93@PC>
Content-Type: text/plain; charset=UTF-8
Message-Id: <1110424911.8870.80.camel@desktop.cunningham.myip.net.au>
Mime-Version: 1.0
Date: Thu, 10 Mar 2005 14:21:51 +1100
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?UTF-8?Q?=EC=A0=95=EC=A4=80?= =?UTF-8?Q?=EB=AA=A9?= Chun-Mok Chung <chunmok@davinci.snu.ac.kr>, Linux Memory Management <linux-mm@kvack.org>
Cc: 'Suspend2 Development' <suspend2-devel@lists.suspend2.net>
List-ID: <linux-mm.kvack.org>

Hi.

On Thu, 2005-03-10 at 14:12, i ?i??ea(C) Chun-Mok Chung wrote:
> You are right. If I don't reduce pageset2 size, swsusp2 works well.
> And image_size_limit function works well, too.
> 
> The problem occurs because of my additional codes.
> I tried reducing pageset2 to enhance resume performance by reducing disk
> I/O time.
> Because my box uses ramdisk, shrink_cache() doesn't write-back dirty page
> to disk and the cache size decrease only a little.
> So, I willing to release dirty pages in inactive_list which are mapped to
> program file and not used any more.

Ah. Now I'm with you.

I wonder whether you'll get better help by talking to the guys who
really understand the memory manager. They're accessible via the
Linux-MM mailing list, which I've cc'd.

Guys, Chun-mok is using a 2.4.19-rmk7-pxa2 kernel. Are you able to give
him some suggestions?

Regards,

Nigel
-- 
Nigel Cunningham
Software Engineer, Canberra, Australia
http://www.cyclades.com
Bus: +61 (2) 6291 9554; Hme: +61 (2) 6292 8028;  Mob: +61 (417) 100 574

Maintainer of Suspend2 Kernel Patches http://suspend2.net

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
