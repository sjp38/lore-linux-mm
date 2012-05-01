Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 6E45B6B0044
	for <linux-mm@kvack.org>; Tue,  1 May 2012 09:25:32 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so2849639pbb.14
        for <linux-mm@kvack.org>; Tue, 01 May 2012 06:25:31 -0700 (PDT)
Date: Tue, 1 May 2012 06:24:09 -0700
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: [PATCH 0/3] vmevent: Implement 'low memory' attribute
Message-ID: <20120501132409.GA22894@lizard>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

Hi all,

Accounting only free pages is very inaccurate for low memory handling,
so we have to be smarter here.

The patch set implements a new attribute, which is blended from various
memory statistics. Vmevent can't expose all the kernel internals to the
userland, as it would make internal Linux MM representation tied to the
ABI. So the ABI itself was made very simple: just number of pages before
we consider that we're low on memory, and the kernel takes care of the
rest.

Thanks,

-- 
Anton Vorontsov
Email: cbouatmailru@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
