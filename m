Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id CDAAA6B13F0
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 09:51:51 -0500 (EST)
Date: Mon, 6 Feb 2012 08:51:48 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/3] move slabinfo.c to tools/vm
In-Reply-To: <20120205081550.GA2247@darkstar.redhat.com>
Message-ID: <alpine.DEB.2.00.1202060851260.393@router.home>
References: <20120205081550.GA2247@darkstar.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Young <dyoung@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, xiyou.wangcong@gmail.com, penberg@kernel.org, fengguang.wu@intel.com

On Sun, 5 Feb 2012, Dave Young wrote:

> We have tools/vm/ folder for vm tools, so move slabinfo.c
> from tools/slub/ to tools/vm/

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
