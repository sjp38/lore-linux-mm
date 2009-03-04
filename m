Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id BBA456B00AD
	for <linux-mm@kvack.org>; Wed,  4 Mar 2009 09:14:06 -0500 (EST)
Received: by rv-out-0708.google.com with SMTP id k29so2827586rvb.26
        for <linux-mm@kvack.org>; Wed, 04 Mar 2009 06:13:50 -0800 (PST)
Date: Wed, 4 Mar 2009 23:13:44 +0900
From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: Re: [PATCH] generic debug pagealloc
Message-ID: <20090304141343.GB7168@localhost.localdomain>
References: <20090303160103.GB5812@localhost.localdomain> <49AD56F3.6020305@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <49AD56F3.6020305@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Jiri Slaby <jirislaby@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 03, 2009 at 05:12:35PM +0100, Jiri Slaby wrote:
> Just an optimisation: pass the i to the dump_broken_mem as a start index.

OK. I'll remove that redundancy in next verserion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
