Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 51FA06B0069
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 12:01:07 -0500 (EST)
Date: Tue, 15 Jan 2013 09:01:05 -0800
From: Zach Brown <zab@zabbo.net>
Subject: Re: [PATCH] mm/slab: add a leak decoder callback
Message-ID: <20130115170105.GP12288@lenny.home.zabbo.net>
References: <1358143419-13074-1-git-send-email-bo.li.liu@oracle.com>
 <0000013c3f0c8af2-361e64b5-f822-4a93-a67e-b2902bb336fc-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0000013c3f0c8af2-361e64b5-f822-4a93-a67e-b2902bb336fc-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Liu Bo <bo.li.liu@oracle.com>, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>

> The merge processing occurs during kmem_cache_create and you are setting
> up the decoder field afterwards! Wont work.

In the thread I suggested providing the callback at destruction:

 http://www.mail-archive.com/linux-btrfs@vger.kernel.org/msg21130.html

I liked that it limits accesibility of the callback to the only path
that uses it.

- z

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
