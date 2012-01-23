Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id A380E6B004D
	for <linux-mm@kvack.org>; Mon, 23 Jan 2012 14:38:25 -0500 (EST)
Received: by ggnk5 with SMTP id k5so1861003ggn.14
        for <linux-mm@kvack.org>; Mon, 23 Jan 2012 11:38:24 -0800 (PST)
Date: Mon, 23 Jan 2012 11:38:08 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Transparent huge pages and shmem?
In-Reply-To: <CB1B361E45A85849902B25342E88900501F504CDD753@ABGEX70E.FSC.NET>
Message-ID: <alpine.LSU.2.00.1201231132030.1677@eggly.anvils>
References: <CB1B361E45A85849902B25342E88900501F504CDD753@ABGEX70E.FSC.NET>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Borzenkov, Andrey" <andrey.borzenkov@ts.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 23 Jan 2012, Borzenkov, Andrey wrote:

> In case of THP enabled kernel - will THP be used for SysV shmem?
> The obvious target is to avoid pre-allocation of huge pages pool
> for databases like Oracle that is required today.

It will one day, yes.  Various people are very interested in THP on
tmpfs/shmem, which serves SysV shm.  But at present THP is limited to
private anonymous pages, and its extension to shared file pages is not
trivial.  I have not heard of anyone making significant progress on
that as yet - but perhaps someone is working on it behind the scenes.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
