Date: Thu, 22 Jan 2004 11:03:42 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: 2.6.2-rc1-mm1
Message-ID: <20040122110342.A9271@infradead.org>
References: <20040122013501.2251e65e.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040122013501.2251e65e.akpm@osdl.org>; from akpm@osdl.org on Thu, Jan 22, 2004 at 01:35:01AM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> sysfs-class-06-raw.patch
>   From: Greg KH <greg@kroah.com>
>   Subject: [PATCH] add sysfs class support for raw devices [06/10]

This one exports get_gendisk, which is a no-go.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
