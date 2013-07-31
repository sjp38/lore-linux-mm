Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 3E7196B0032
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 04:17:05 -0400 (EDT)
Message-ID: <51F8C7F4.9020504@parallels.com>
Date: Wed, 31 Jul 2013 12:16:52 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [patch 2/2] [PATCH] mm: Save soft-dirty bits on file pages
References: <20130730204154.407090410@gmail.com> <20130730204654.966378702@gmail.com>
In-Reply-To: <20130730204654.966378702@gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, luto@amacapital.net, gorcunov@openvz.org, mpm@selenic.com, xiaoguangrong@linux.vnet.ibm.com, mtosatti@redhat.com, kosaki.motohiro@gmail.com, sfr@canb.auug.org.au, peterz@infradead.org, aneesh.kumar@linux.vnet.ibm.com

On 07/31/2013 12:41 AM, Cyrill Gorcunov wrote:

> Andy reported that if file page get reclaimed we loose soft-dirty bit
> if it was there, so save _PAGE_BIT_SOFT_DIRTY bit when page address
> get encoded into pte entry. Thus when #pf happens on such non-present
> pte we can restore it back.
> 
> Reported-by: Andy Lutomirski <luto@amacapital.net>
> Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>

Acked-by: Pavel Emelyanov <xemul@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
