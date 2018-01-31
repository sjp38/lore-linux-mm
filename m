Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 925A06B0006
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 19:00:45 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id v14so1187003wmd.3
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 16:00:45 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n17si8881291wmd.57.2018.01.30.16.00.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jan 2018 16:00:44 -0800 (PST)
Date: Tue, 30 Jan 2018 16:00:41 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] tools, vm: new option to specify kpageflags file
Message-Id: <20180130160041.ced8e9bbb4741494147f476f@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.10.1801301458180.153857@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1801301458180.153857@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 30 Jan 2018 15:01:01 -0800 (PST) David Rientjes <rientjes@google.com> wrote:

> page-types currently hardcodes /proc/kpageflags as the file to parse.  
> This works when using the tool to examine the state of pageflags on the 
> same system, but does not allow storing a snapshot of pageflags at a given 
> time to debug issues nor on a different system.
> 
> This allows the user to specify a saved version of kpageflags with a new 
> page-types -F option.
> 

This, methinks:

--- a/tools/vm/page-types.c~tools-vm-new-option-to-specify-kpageflags-file-fix
+++ a/tools/vm/page-types.c
@@ -791,7 +791,7 @@ static void usage(void)
 "            -N|--no-summary            Don't show summary info\n"
 "            -X|--hwpoison              hwpoison pages\n"
 "            -x|--unpoison              unpoison pages\n"
-"            -F|--kpageflags            kpageflags file to parse\n"
+"            -F|--kpageflags filename   kpageflags file to parse\n"
 "            -h|--help                  Show this usage message\n"
 "flags:\n"
 "            0x10                       bitfield format, e.g.\n"
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
