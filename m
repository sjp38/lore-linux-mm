Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 809336B005D
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 10:13:13 -0500 (EST)
Message-ID: <50C5FC06.8020104@tilera.com>
Date: Mon, 10 Dec 2012 10:13:10 -0500
From: Chris Metcalf <cmetcalf@tilera.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 1/8] mm, vmalloc: change iterating a vmlist to find_vm_area()
References: <1354810175-4338-1-git-send-email-js1304@gmail.com> <1354810175-4338-2-git-send-email-js1304@gmail.com>
In-Reply-To: <1354810175-4338-2-git-send-email-js1304@gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Russell King <rmk+kernel@arm.linux.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kexec@lists.infradead.org, Guan Xuetao <gxt@mprc.pku.edu.cn>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>

On 12/6/2012 11:09 AM, Joonsoo Kim wrote:
> The purpose of iterating a vmlist is finding vm area with specific
> virtual address. find_vm_area() is provided for this purpose
> and more efficient, because it uses a rbtree.
> So change it.

If you get an Acked-by for the x86 change, feel free to apply it to the tile file as well.  You'll note that for tile it's under an #if 0, which in retrospect I shouldn't have pushed anyway.  So I don't feel strongly :-)

FWIW, the change certainly seems at least plausible to me.

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
