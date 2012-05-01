Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 406B66B0044
	for <linux-mm@kvack.org>; Tue,  1 May 2012 13:36:05 -0400 (EDT)
Received: by yenm8 with SMTP id m8so2887081yen.14
        for <linux-mm@kvack.org>; Tue, 01 May 2012 10:36:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120430112910.14137.28935.stgit@zurg>
References: <20120430112903.14137.81692.stgit@zurg> <20120430112910.14137.28935.stgit@zurg>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Tue, 1 May 2012 13:35:43 -0400
Message-ID: <CAHGf_=rWDMMv2dKz3paV2MnjsCNWBa2BaUTi+RnDo8DZ4zEr=g@mail.gmail.com>
Subject: Re: [PATCH RFC 3/3] proc/smaps: show amount of hwpoison pages
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>

On Mon, Apr 30, 2012 at 7:29 AM, Konstantin Khlebnikov
<khlebnikov@openvz.org> wrote:
> This patch adds line "HWPoinson: <size> kB" into /proc/pid/smaps if
> CONFIG_MEMORY_FAILURE=y and some HWPoison pages were found.
> This may be useful for searching applications which use a broken memory.

I dislike "maybe useful" claim. If we don't know exact motivation of a feature,
we can't maintain them especially when a bugfix can't avoid ABI change.

Please write down exact use case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
