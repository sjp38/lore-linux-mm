Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 94B1E6B0044
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 10:46:21 -0400 (EDT)
Received: by dadv6 with SMTP id v6so2074764dad.14
        for <linux-mm@kvack.org>; Wed, 21 Mar 2012 07:46:20 -0700 (PDT)
Date: Wed, 21 Mar 2012 07:46:17 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 05/16] mm/drivers: use vm_flags_t for vma flags
Message-ID: <20120321144617.GA14149@kroah.com>
References: <20120321065140.13852.52315.stgit@zurg>
 <20120321065633.13852.11903.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20120321065633.13852.11903.stgit@zurg>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, Mauro Carvalho Chehab <mchehab@infradead.org>, linux-mm@kvack.org, Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>, John Stultz <john.stultz@linaro.org>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, linux-media@vger.kernel.org

On Wed, Mar 21, 2012 at 10:56:33AM +0400, Konstantin Khlebnikov wrote:
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> Cc: linux-media@vger.kernel.org
> Cc: devel@driverdev.osuosl.org
> Cc: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
> Cc: Mauro Carvalho Chehab <mchehab@infradead.org>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: John Stultz <john.stultz@linaro.org>
> Cc: "Arve Hjonnevag" <arve@android.com>

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
