Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id EA0B96B02B0
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 22:28:28 -0500 (EST)
Received: by yhoo21 with SMTP id o21so1173576yho.14
        for <linux-mm@kvack.org>; Tue, 13 Dec 2011 19:28:27 -0800 (PST)
Date: Tue, 13 Dec 2011 19:28:24 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/hugetlb.c: cleanup to use long vars instead of int
 in region_count
In-Reply-To: <4EE6F24B.7050204@gmail.com>
Message-ID: <alpine.DEB.2.00.1112131928110.3208@chino.kir.corp.google.com>
References: <4EE6F24B.7050204@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Sheng-Hui <shhuiw@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 13 Dec 2011, Wang Sheng-Hui wrote:

> args f & t and fields from & to of struct file_region are defined
> as long. Use long instead of int to type the temp vars.
> 
> Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
