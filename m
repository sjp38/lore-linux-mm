Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 891476B006E
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 12:13:45 -0400 (EDT)
Received: by ieclw3 with SMTP id lw3so1386274iec.2
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 09:13:45 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0141.hostedemail.com. [216.40.44.141])
        by mx.google.com with ESMTP id ie16si107065igb.54.2015.03.24.09.13.44
        for <linux-mm@kvack.org>;
        Tue, 24 Mar 2015 09:13:44 -0700 (PDT)
Message-ID: <1427213619.5642.34.camel@perches.com>
Subject: Re: [RFC PATCH 01/11] sysctl: make some functions unstatic to
 access by arch/lib
From: Joe Perches <joe@perches.com>
Date: Tue, 24 Mar 2015 09:13:39 -0700
In-Reply-To: <1427202642-1716-2-git-send-email-tazaki@sfc.wide.ad.jp>
References: <1427202642-1716-1-git-send-email-tazaki@sfc.wide.ad.jp>
	 <1427202642-1716-2-git-send-email-tazaki@sfc.wide.ad.jp>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
Cc: linux-arch@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Jhristoph Lameter <cl@linux.com>, Jekka Enberg <penberg@kernel.org>, Javid Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jndrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Rusty Russell <rusty@rustcorp.com.au>, Mathieu Lacage <mathieu.lacage@gmail.com>

On Tue, 2015-03-24 at 22:10 +0900, Hajime Tazaki wrote:
> libos (arch/lib) emulates a sysctl-like interface by a function call of
> userspace by enumerating sysctl tree from sysctl_table_root. It requires
> to be publicly accessible to this symbol and related functions.
[]
> diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
[]
> @@ -77,7 +77,7 @@ static int namecmp(const char *name1, int len1, const char *name2, int len2)
>  }
>  
>  /* Called under sysctl_lock */
> -static struct ctl_table *find_entry(struct ctl_table_header **phead,
> +struct ctl_table *find_entry(struct ctl_table_header **phead,

find_entry and all of the <foo>_entry functions below it
are overly generic names.  Maybe prefix with ctl_table_


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
