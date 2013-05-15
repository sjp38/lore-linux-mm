Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 44F576B0002
	for <linux-mm@kvack.org>; Wed, 15 May 2013 08:02:38 -0400 (EDT)
Message-Id: <201305151202.r4FC29c7099530@www262.sakura.ne.jp>
Subject: Re: [3.10-rc1 SLUB?] mm: kmemcheck warning.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Date: Wed, 15 May 2013 21:02:09 +0900
References: <201305142105.EBE34832.LOOHFtVSFJOFMQ@I-love.SAKURA.ne.jp>
In-Reply-To: <201305142105.EBE34832.LOOHFtVSFJOFMQ@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset="ISO-2022-JP"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vegardno@ifi.uio.no, penberg@kernel.org, linux-kernel@vger.kernel.org

Adding kmemcheck maintainer, for this might be false positives.

Regarding https://lkml.org/lkml/2013/5/14/248 (this thread) and
https://lkml.org/lkml/2013/5/14/250 (similar one), I tried to run bisection,
but I couldn\'t find the culprit. This problem seems to exist at least since
Linux 3.6. (I couldn\'t test Linux 3.5 and earlier because the kernel dies with
\"divide error\" depending on config/environment).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
