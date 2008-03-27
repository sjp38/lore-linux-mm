Received: by py-out-1112.google.com with SMTP id f47so4283277pye.20
        for <linux-mm@kvack.org>; Thu, 27 Mar 2008 09:49:20 -0700 (PDT)
Message-ID: <2f11576a0803270949g5931445fp8410c898c3685437@mail.gmail.com>
Date: Fri, 28 Mar 2008 01:49:20 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] Uninline zonelist iterator helper functions
In-Reply-To: <20080327155144.GA7120@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080327155144.GA7120@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com, kosaki.motohiro@gmail.com
List-ID: <linux-mm.kvack.org>

Hi

On Fri, Mar 28, 2008 at 12:51 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> for_each_zone_zonelist_nodemask() uses large inlined helpers. The number of
>  callsites using it means that the size of the text section is increased.
>  This patch uninlines the helpers to reduce the amount of text bloat.
>
>  Signed-off-by: Mel Gorman <mel@csn.ul.ie>

I found no bug :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
