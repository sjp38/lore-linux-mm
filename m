Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 9EBD96B0068
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 16:12:58 -0400 (EDT)
Received: by bkcjc3 with SMTP id jc3so3173332bkc.14
        for <linux-mm@kvack.org>; Mon, 02 Jul 2012 13:12:56 -0700 (PDT)
Date: Mon, 2 Jul 2012 23:12:47 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH] mm: Fix signal SIGFPE in slabinfo.c.
In-Reply-To: <alpine.DEB.2.00.1207021448340.31690@router.home>
Message-ID: <alpine.LFD.2.02.1207022310580.1904@tux.localdomain>
References: <201206260930282811070@gmail.com> <alpine.DEB.2.00.1207021448340.31690@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "fengguang.wu" <fengguang.wu@intel.com>, majianpeng <majianpeng@gmail.com>, linux-mm@kvack.org

On Mon, 2 Jul 2012, Christoph Lameter wrote:
> Acked-by: Christoph Lameter <cl@linux.com>

Applied, thanks!

[ btw, please use the penberg@kernel.org email address.
  I don't really read the @cs.helsinki.fi one that much. ]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
