Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id C5ECF6B002B
	for <linux-mm@kvack.org>; Sat, 15 Dec 2012 17:29:22 -0500 (EST)
Date: Sat, 15 Dec 2012 22:34:48 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] fadvise: perform WILLNEED readahead in a workqueue
Message-ID: <20121215223448.08272fd5@pyramind.ukuu.org.uk>
In-Reply-To: <20121215005448.GA7698@dcvr.yhbt.net>
References: <20121215005448.GA7698@dcvr.yhbt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Wong <normalperson@yhbt.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 15 Dec 2012 00:54:48 +0000
Eric Wong <normalperson@yhbt.net> wrote:

> Applications streaming large files may want to reduce disk spinups and
> I/O latency by performing large amounts of readahead up front


How does it compare benchmark wise with a user thread or using the
readahead() call ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
