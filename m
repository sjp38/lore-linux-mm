Received: by nz-out-0506.google.com with SMTP id i11so166451nzh.26
        for <linux-mm@kvack.org>; Thu, 24 Jan 2008 04:19:46 -0800 (PST)
Message-ID: <cfd9edbf0801240419t669c9d9cl4cf0f821599fc7ad@mail.gmail.com>
Date: Thu, 24 Jan 2008 13:19:45 +0100
From: "=?ISO-8859-1?Q?Daniel_Sp=E5ng?=" <daniel.spang@gmail.com>
Subject: Re: [RFC][PATCH 3/8] mem_notify v5: introduce /dev/mem_notify new device (the core of this patch series)
In-Reply-To: <20080124132014.1769.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080124130348.1760.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080124132014.1769.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Marcelo Tosatti <marcelo@kvack.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

Hi KOSAKI,

On 1/24/08, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> +#define PROC_WAKEUP_GUARD  (10*HZ)
[...]
> +       timeout = info->last_proc_notify + PROC_WAKEUP_GUARD;

If only one or a few processes are using the system I think 10 seconds
is a little long time to wait before they get the notification again.
Can we decrease this value? Or make it configurable under /proc? Or
make it lower with fewer users? Something like:

timeout = info->last_proc_notify + min(mem_notify_users, PROC_WAKEUP_GUARD);

Cheers,
Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
