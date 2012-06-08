Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 78E126B0070
	for <linux-mm@kvack.org>; Thu,  7 Jun 2012 23:17:33 -0400 (EDT)
Received: by qafl39 with SMTP id l39so653670qaf.9
        for <linux-mm@kvack.org>; Thu, 07 Jun 2012 20:17:32 -0700 (PDT)
Message-ID: <4FD16EC8.60502@gmail.com>
Date: Thu, 07 Jun 2012 23:17:28 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] vmstat: Implement refresh_vm_stats()
References: <20120601122118.GA6128@lizard> <1338553446-22292-1-git-send-email-anton.vorontsov@linaro.org>
In-Reply-To: <1338553446-22292-1-git-send-email-anton.vorontsov@linaro.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: Pekka Enberg <penberg@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

(6/1/12 8:24 AM), Anton Vorontsov wrote:
> This function forcibly flushes per-cpu vmstat diff counters to the
> global counters.
> 
> Note that we don't try to flush percpu pagesets, the pcp will be
> still flushed once per 3 seconds.
> 
> Signed-off-by: Anton Vorontsov<anton.vorontsov@linaro.org>

No.

This is insane. Your patch improved vmevent accuracy a _bit_. But instead of,
decrease a performance of large systems. That's no good deal. 99% user never
uses vmevent.

MOREOVER, this patch don't solve vmevent accuracy issue AT ALL. because of,
a second is enough big to make large inaccuracy. Modern cpus are fast. Guys,
the fact is, user land monitor can't use implicit batch likes vmstat. That's
a reason why perf don't use vmstat. I suggest you see perf APIs. It may bring
you good inspiration.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
