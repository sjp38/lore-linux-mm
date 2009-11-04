Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9FC3B6B0087
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 08:30:13 -0500 (EST)
Date: Wed, 04 Nov 2009 05:30:29 -0800 (PST)
Message-Id: <20091104.053029.166783766.davem@davemloft.net>
Subject: Re: [PATCHv7 1/3] tun: export underlying socket
From: David Miller <davem@davemloft.net>
In-Reply-To: <20091103172400.GB5591@redhat.com>
References: <cover.1257267892.git.mst@redhat.com>
	<20091103172400.GB5591@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: mst@redhat.com
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, gregory.haskins@gmail.com, rusty@rustcorp.com.au, s.hetze@linux-ag.com
List-ID: <linux-mm.kvack.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Tue, 3 Nov 2009 19:24:00 +0200

> Assuming it's okay with davem, I think it makes sense to merge this
> patch through Rusty's tree because vhost is the first user of the new
> interface.  Posted here for completeness.

I'm fine with that, please add my:

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
