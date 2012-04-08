Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 0817E6B0044
	for <linux-mm@kvack.org>; Sun,  8 Apr 2012 19:36:14 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so3999909bkw.14
        for <linux-mm@kvack.org>; Sun, 08 Apr 2012 16:36:13 -0700 (PDT)
Date: Mon, 9 Apr 2012 03:36:05 +0400
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: [PATCH 0/3] vmevent: Some fixes + a new event type
Message-ID: <20120408233550.GA3791@panacea>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org

Hi all,

This small patch set fixes a bug in the vmevent core, plus makes the
vmevent-test buildable w/o unneded SDL library.

Plus, we add a new 'cross' event type: the event will trigger whenever
a value crosses a user-specified threshold. It works two-way, i.e. when
a value crosses the threshold from a lesser values side to a greater 
values side, and vice versa.

We use the event type in an userspace low-memory killer: we get a
notification when memory becomes low, so we start freeing memory by
killing unneeded processes, and we get notification when memory hits
the threshold from another side, so we know that we freed enough of
memory.

The patches are against

	git://github.com/penberg/linux.git vmevent/core

Thanks!

-- 
Anton Vorontsov
Email: cbouatmailru@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
