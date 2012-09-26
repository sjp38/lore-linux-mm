Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id C8EC86B005D
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 05:54:08 -0400 (EDT)
Received: by wibhm4 with SMTP id hm4so558910wib.8
        for <linux-mm@kvack.org>; Wed, 26 Sep 2012 02:54:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1348649419-16494-3-git-send-email-minchan@kernel.org>
References: <1348649419-16494-1-git-send-email-minchan@kernel.org>
	<1348649419-16494-3-git-send-email-minchan@kernel.org>
Date: Wed, 26 Sep 2012 12:54:06 +0300
Message-ID: <CAOJsxLHZ5Zq5_gsLXVkJcixAHkYm78t=K0AnfnLHU30dqSTesg@mail.gmail.com>
Subject: Re: [PATCH 2/3] zram: promote zram from staging
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Sep 26, 2012 at 11:50 AM, Minchan Kim <minchan@kernel.org> wrote:
> It's time to promote zram from staging because zram is in staging
> for a long time and is improved by many contributors so code is
> very clean. Most important issue, zram's dependency with x86 is
> solved by making zsmalloc portable. In addition, many embedded
> product uses zram in real practive so I think there is no reason
> to prevent promotion now.
>
> Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>
> Cc: Nitin Gupta <ngupta@vflare.org>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

FWIW,

Acked-by: Pekka Enberg <penberg@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
