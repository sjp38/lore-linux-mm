Received: by fk-out-0910.google.com with SMTP id z22so1200986fkz.6
        for <linux-mm@kvack.org>; Sun, 29 Jun 2008 18:37:34 -0700 (PDT)
Message-ID: <21d7e9970806291837y39221513i8537fe361f23eeeb@mail.gmail.com>
Date: Mon, 30 Jun 2008 11:37:34 +1000
From: "Dave Airlie" <airlied@gmail.com>
Subject: removing pages from the kernel mappings completely....
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Another thing we are contemplating to avoid having to do a lot of
changes to kernel mappings to move pages from cached to uncached
mappings, is to use highmem pages where we can, but also remove a set
of pages from the kernel page mappings if we didn't have any highmem.

This would allow us to remove those pages when we bring pages into a
pool, and then we can control the userspace and kernel maps of these
pages for cached/uncached uses from that point on, without having to
go through a page remapping for the kernel pages every time.

Dave.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
