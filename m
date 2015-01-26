Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 55F2A6B0032
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 18:19:45 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id fl12so14987593pdb.6
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 15:19:45 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ua4si3070175pbc.181.2015.01.26.15.19.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jan 2015 15:19:44 -0800 (PST)
Date: Mon, 26 Jan 2015 15:19:42 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/zsmalloc: add log for module load/unload
Message-Id: <20150126151942.2dd88d5221423e7379b43a06@linux-foundation.org>
In-Reply-To: <1422107321-9973-1-git-send-email-opensource.ganesh@gmail.com>
References: <1422107321-9973-1-git-send-email-opensource.ganesh@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: minchan@kernel.org, ngupta@vflare.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 24 Jan 2015 21:48:41 +0800 Ganesh Mahendran <opensource.ganesh@gmail.com> wrote:

> Sometimes, we want to know whether a module is loaded or unloaded
> from the log.

Why?  What's special about zsmalloc?

Please provide much better justification than this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
