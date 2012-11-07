Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 23F886B0044
	for <linux-mm@kvack.org>; Wed,  7 Nov 2012 09:16:33 -0500 (EST)
Message-ID: <509A6DDA.9090109@redhat.com>
Date: Wed, 07 Nov 2012 09:19:06 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC 3/3] man-pages: Add man page for vmpressure_fd(2)
References: <20121107105348.GA25549@lizard> <20121107110152.GC30462@lizard>
In-Reply-To: <20121107110152.GC30462@lizard>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: Mel Gorman <mgorman@suse.de>, Pekka Enberg <penberg@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, linux-man@vger.kernel.org

On 11/07/2012 06:01 AM, Anton Vorontsov wrote:

>     Configuration
>         vmpressure_fd(2) accepts vmpressure_config structure to configure
>         the notifications:
>
>         struct vmpressure_config {
>              __u32 size;
>              __u32 threshold;
>         };
>
>         size is a part of ABI  versioning  and  must  be  initialized  to
>         sizeof(struct vmpressure_config).

If you want to use a versioned ABI, why not pass in an
actual version number?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
