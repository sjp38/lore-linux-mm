Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id CA4C36B004D
	for <linux-mm@kvack.org>; Thu,  3 May 2012 04:10:13 -0400 (EDT)
Received: by yenm8 with SMTP id m8so2134626yen.14
        for <linux-mm@kvack.org>; Thu, 03 May 2012 01:10:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120501132409.GA22894@lizard>
References: <20120501132409.GA22894@lizard>
Date: Thu, 3 May 2012 11:10:12 +0300
Message-ID: <CAOJsxLGxKdDnw6RU=1C3VVrwZJ53k_r6gOddYkjxQxjc1-kRXg@mail.gmail.com>
Subject: Re: [PATCH 0/3] vmevent: Implement 'low memory' attribute
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Tue, May 1, 2012 at 4:24 PM, Anton Vorontsov
<anton.vorontsov@linaro.org> wrote:
> Accounting only free pages is very inaccurate for low memory handling,
> so we have to be smarter here.

Can you elaborate on what kind of problems there are with tracking free pages?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
