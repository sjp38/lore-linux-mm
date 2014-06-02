Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f180.google.com (mail-yk0-f180.google.com [209.85.160.180])
	by kanga.kvack.org (Postfix) with ESMTP id 71A876B0036
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 11:56:04 -0400 (EDT)
Received: by mail-yk0-f180.google.com with SMTP id q9so3788835ykb.25
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 08:56:04 -0700 (PDT)
Received: from SMTP02.CITRIX.COM (smtp02.citrix.com. [66.165.176.63])
        by mx.google.com with ESMTPS id r3si24062814yhl.132.2014.06.02.08.56.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Jun 2014 08:56:03 -0700 (PDT)
Message-ID: <538C9E3F.3000403@citrix.com>
Date: Mon, 2 Jun 2014 16:54:39 +0100
From: David Vrabel <david.vrabel@citrix.com>
MIME-Version: 1.0
Subject: Re: [PATCH] improve __GFP_COLD/__GFP_ZERO interaction
References: <538CAA520200007800016E87@mail.emea.novell.com>
In-Reply-To: <538CAA520200007800016E87@mail.emea.novell.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Beulich <JBeulich@suse.com>, linux-mm@kvack.org
Cc: mingo@elte.hu, tglx@linutronix.de, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, hpa@zytor.com

On 02/06/14 15:46, Jan Beulich wrote:
> 
> --- 3.15-rc8/drivers/xen/balloon.c
> +++ 3.15-rc8-clear-cold-highpage/drivers/xen/balloon.c

Please split the Xen part out into a separate patch since this is a
useful cleanup either way.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
