Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 174C66B0035
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 16:04:28 -0400 (EDT)
Received: by mail-ie0-f174.google.com with SMTP id lx4so2159636iec.33
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 13:04:27 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id x13si7615415icq.42.2014.06.25.13.04.27
        for <linux-mm@kvack.org>;
        Wed, 25 Jun 2014 13:04:27 -0700 (PDT)
Date: Wed, 25 Jun 2014 13:04:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 -next 0/9] CMA: generalize CMA reserved area
 management code
Message-Id: <20140625130425.609ad4293781f5ac81772bf9@linux-foundation.org>
In-Reply-To: <53AAC1B4.5000204@samsung.com>
References: <1402897251-23639-1-git-send-email-iamjoonsoo.kim@lge.com>
	<539EB4C7.3080106@samsung.com>
	<20140617012507.GA6825@js1304-P5Q-DELUXE>
	<20140618135144.297c785260f9e2aebead867c@linux-foundation.org>
	<53AAC1B4.5000204@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Gleb Natapov <gleb@kernel.org>, Alexander Graf <agraf@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Wed, 25 Jun 2014 14:33:56 +0200 Marek Szyprowski <m.szyprowski@samsung.com> wrote:

> > That's probably easier.  Marek, I'll merge these into -mm (and hence
> > -next and git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git)
> > and shall hold them pending you review/ack/test/etc, OK?
> 
> Ok. I've tested them and they work fine. I'm sorry that you had to wait for
> me for a few days. You can now add:
> 
> Acked-and-tested-by: Marek Szyprowski <m.szyprowski@samsung.com>

Thanks.

> I've also rebased my pending patches onto this set (I will send them soon).
> 
> The question is now if you want to keep the discussed patches in your 
> -mm tree,
> or should I take them to my -next branch. If you like to keep them, I assume
> you will also take the patches which depends on the discussed changes.

Yup, that works.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
