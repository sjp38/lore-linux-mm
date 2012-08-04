Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 1021D6B0068
	for <linux-mm@kvack.org>; Sat,  4 Aug 2012 04:59:06 -0400 (EDT)
Received: by wibhm2 with SMTP id hm2so244669wib.2
        for <linux-mm@kvack.org>; Sat, 04 Aug 2012 01:59:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <b9bee363-321e-409a-bc8e-65ffed8a1dc5@default>
References: <c31aaed4-9d50-4cdf-b794-367fc5850483@default>
	<CAOJsxLEhW=b3En737d5751xufW2BLehPc2ZGGG1NEtRVSo3=jg@mail.gmail.com>
	<b9bee363-321e-409a-bc8e-65ffed8a1dc5@default>
Date: Sat, 4 Aug 2012 11:59:04 +0300
Message-ID: <CAOJsxLHe6egmMWdEAGj7DGHHX-hqYMhVWDggny9CsT0H-DOL-g@mail.gmail.com>
Subject: Re: [RFC/PATCH] zcache/ramster rewrite and promotion
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Dan,

On Wed, Aug 1, 2012 at 12:13 AM, Dan Magenheimer
<dan.magenheimer@oracle.com> wrote:
> Ramster does the same thing but manages it peer-to-peer across
> multiple systems using kernel sockets.  One could argue that
> the dependency on sockets makes it more of a driver than "mm"
> but ramster is "memory management" too, just a bit more exotic.

How do you configure it? Can we move parts of the network protocol under
net/ramster or something?

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
