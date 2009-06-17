Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 332196B007E
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 13:28:04 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 2389F82C3FD
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 13:45:05 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id f23mQIvln65K for <linux-mm@kvack.org>;
	Wed, 17 Jun 2009 13:45:00 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 7AF3282C407
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 13:45:00 -0400 (EDT)
Date: Wed, 17 Jun 2009 13:00:44 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 5/9] percpu: clean up percpu variable definitions
In-Reply-To: <1245210060-24344-6-git-send-email-tj@kernel.org>
Message-ID: <alpine.DEB.1.10.0906171300190.1695@gentwo.org>
References: <1245210060-24344-1-git-send-email-tj@kernel.org> <1245210060-24344-6-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, mingo@elte.hu, kyle@mcmartin.ca, Jesper.Nilsson@axis.com, benh@kernel.crashing.org, paulmck@linux.vnet.ibm.com, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Jens Axboe <jens.axboe@oracle.com>, Dave Jones <davej@redhat.com>, Jeremy Fitzhardinge <jeremy@xensource.com>, linux-mm <linux-mm@kvack.org>, "David S. Miller" <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>


The wrapping fixes could have been put in the earlier patch.

Reviewed-by: Christoph Lameter <cl@linux-foundation.org>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
